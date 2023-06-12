//
//  File.swift
//
//
//  Created by Qiwei Li on 6/12/23.
//

import Foundation
import PluginInterface
import SwiftyJSON

enum AIDocsConfigError: LocalizedError {
    case noVercelTokenSet
    case noConfigIdSet
    case noTeamIdSet
    case missingValues

    var errorDescription: String? {
        switch self {
            case .noVercelTokenSet:
                return "No Vercel token set"
            case .noConfigIdSet:
                return "No config id set"
            case .noTeamIdSet:
                return "No team ID set"
            case .missingValues:
                return "No config values fetched from the server. You need to fetch first!"
        }
    }
}

class AIDocsConfigModel: ObservableObject {
    let endpoint = "http://localhost:3000"

    @Published var schema: JSON? = nil
    @Published var values: JSON? = nil
    @Published var isLoading = false
    @Published var saving = false
    @Published var saved = false
    @Published var rawConfigs: [EdgeConfig] = []

    private var storeUtils: StoreUtilsProtocol!
    private var panelUtils: NSPanelUtilsProtocol!
    private var plugin: (any PluginInterfaceProtocol)!

    func update(storeUtils: StoreUtilsProtocol, panelUtils: NSPanelUtilsProtocol, plugin: any PluginInterfaceProtocol) {
        self.storeUtils = storeUtils
        self.panelUtils = panelUtils
        self.plugin = plugin
    }

    @MainActor
    func fetch() async {
        do {
            self.isLoading = true
            self.values = nil
            self.schema = nil
            self.rawConfigs = []
            let schema = await self.fetchSchema()
            let values = try await self.fetchValues()
            self.schema = schema
            self.values = EdgeConfig.toJSONMap(configs: values)
            self.rawConfigs = values

        } catch {
            self.panelUtils.alert(title: "Unable to fetch config", subtitle: error.localizedDescription, okButtonText: nil, alertStyle: .critical)
        }
        self.isLoading = false
    }

    @MainActor
    internal func fetchValues() async throws -> [EdgeConfig] {
        let apiEndpoint = URL(string: "https://api.vercel.com/v1/edge-config")!
        let teamID: String? = self.storeUtils.get(forKey: .StoreKey.teamId.rawValue, from: self.plugin)
        let vercelToken: String? = self.storeUtils.get(forKey: .StoreKey.vercelToken.rawValue, from: self.plugin)
        let configId: String? = self.storeUtils.get(forKey: .StoreKey.configId.rawValue, from: self.plugin)

        guard let vercelToken = vercelToken else {
            throw AIDocsConfigError.noVercelTokenSet
        }

        guard let configName = configId else {
            throw AIDocsConfigError.noConfigIdSet
        }

        guard let teamID = teamID else {
            throw AIDocsConfigError.noTeamIdSet
        }

        let url = apiEndpoint
            .appending(path: configName)
            .appending(path: "items")
            .appending(queryItems: [.init(name: "teamId", value: teamID)])

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(vercelToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([EdgeConfig].self, from: data)
    }

    @MainActor
    internal func fetchSchema() async -> JSON {
        let url = URL(string: endpoint)!.appending(path: "config")
        let (data, _) = try! await URLSession.shared.data(from: url)
        let json = try! JSON(data: data)
        return json
    }

    @MainActor
    func save() async {
        do {
            self.saving = true
            self.saved = false
            let apiEndpoint = URL(string: "https://api.vercel.com/v1/edge-config")!
            let teamID: String? = self.storeUtils.get(forKey: .StoreKey.teamId.rawValue, from: self.plugin)
            let vercelToken: String? = self.storeUtils.get(forKey: .StoreKey.vercelToken.rawValue, from: self.plugin)
            let configId: String? = self.storeUtils.get(forKey: .StoreKey.configId.rawValue, from: self.plugin)

            guard let vercelToken = vercelToken else {
                throw AIDocsConfigError.noVercelTokenSet
            }

            guard let configName = configId else {
                throw AIDocsConfigError.noConfigIdSet
            }

            guard let teamID = teamID else {
                throw AIDocsConfigError.noTeamIdSet
            }

            guard let values = values else {
                throw AIDocsConfigError.missingValues
            }

            let differences = EdgeConfig.findDifferences(configs: self.rawConfigs, from: values)
            // 'https://api.vercel.com/v1/edge-config/your_edge_config_id_here/items?teamId=your_team_id_here';
            let url = apiEndpoint
                .appending(path: configName)
                .appending(path: "items")
                .appending(queryItems: [.init(name: "teamId", value: teamID)])

            let data = try JSONEncoder().encode(EdgeConfig.toUpdateEdgeConfigDto(configs: differences))
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.httpBody = data
            request.setValue("Bearer \(vercelToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

            let _ = try await URLSession.shared.data(for: request)
            self.saved = true

        } catch {
            self.panelUtils.alert(title: "Unable to save config", subtitle: error.localizedDescription, okButtonText: nil, alertStyle: .critical)
        }

        self.saving = false
    }
}
