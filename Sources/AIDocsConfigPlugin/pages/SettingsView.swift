//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 6/12/23.
//

import PluginInterface
import SwiftUI

extension String {
    enum StoreKey: String {
        case vercelToken = "vercel-token"
        case teamId = "team-id"
        case apiEndpoint = "api-endpoint"
        case configId = "config-id"
    }
}

struct SettingsView: View {
    let storeUtils: StoreUtilsProtocol
    let plugin: any PluginInterfaceProtocol

    @State var vercelToken: String = ""
    @State var teamID: String = ""
    @State var apiEndpoint: String = ""
    @State var configId: String = ""

    @State var saved: Bool = false

    var body: some View {
        Form {
            TextField("Vercel Token", text: $vercelToken)
            TextField("Team ID", text: $teamID)
            TextField("API Endpoint", text: $apiEndpoint)
            TextField("Config Id", text: $configId)

            Button {
                Task {
                    await save()
                }
            } label: {
                if saved {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .frame(width: 50.0, height: 20.0)

                } else {
                    Text("Save")
                        .frame(width: 50.0, height: 20.0)
                }
            }
        }
        .onAppear {
            vercelToken = storeUtils.get(forKey: .StoreKey.vercelToken.rawValue, from: plugin) ?? ""
            teamID = storeUtils.get(forKey: .StoreKey.teamId.rawValue, from: plugin) ?? ""
            apiEndpoint = storeUtils.get(forKey: .StoreKey.apiEndpoint.rawValue, from: plugin) ?? ""
            configId = storeUtils.get(forKey: .StoreKey.configId.rawValue, from: plugin) ?? ""
        }
    }

    func save() async {
        saved = true
        storeUtils.set(vercelToken, forKey: .StoreKey.vercelToken.rawValue, from: plugin)
        storeUtils.set(teamID, forKey: .StoreKey.teamId.rawValue, from: plugin)
        storeUtils.set(apiEndpoint, forKey: .StoreKey.apiEndpoint.rawValue, from: plugin)
        storeUtils.set(configId, forKey: .StoreKey.configId.rawValue, from: plugin)
        try? await Task.sleep(for: .seconds(3))
        saved = false
    }
}
