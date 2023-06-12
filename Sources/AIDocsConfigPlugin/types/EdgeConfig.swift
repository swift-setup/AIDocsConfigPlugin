//
//  File.swift
//
//
//  Created by Qiwei Li on 6/12/23.
//

import AnyCodable
import Foundation
import SwiftyJSON

struct EdgeConfig: Codable {
    let edgeConfigId: String
    let key: String
    let value: AnyCodable

    static func toJSONMap(configs: [EdgeConfig]) -> JSON {
        var json = JSON()
        for config in configs {
            json[config.key] = JSON(config.value.value)
        }
        return json
    }

    static func findDifferences(configs: [EdgeConfig], from values: JSON) -> [EdgeConfig] {
        var differences: [EdgeConfig] = []
        for config in configs {
            let value = values[config.key].rawValue
            let anyCodableValue = AnyCodable(value)
            if config.value != anyCodableValue {
                differences.append(.init(edgeConfigId: config.edgeConfigId, key: config.key, value: anyCodableValue))
            }
        }
        return differences
    }
    
    static func toUpdateEdgeConfigDto(configs: [EdgeConfig]) -> UpdateEdgeConfigDto {
        return UpdateEdgeConfigDto(items: configs.map{.init(operation: "update", key: $0.key, value: $0.value)})
    }
}

struct UpdateEdgeConfigDto: Codable {
    let items: [Config]

    struct Config: Codable {
        let operation: String
        let key: String
        let value: AnyCodable
    }
}
