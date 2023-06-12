//
//  File.swift
//
//
//  Created by Qiwei Li on 6/12/23.
//

import Foundation

struct JSONSchema: Codable {
    let schema: String
    let type: String
    let properties: [String: Property]
    let jsonSchemaRequired: [String]

    enum CodingKeys: String, CodingKey {
        case schema
        case type, properties
        case jsonSchemaRequired
    }
}

struct Property: Codable {
    let type: String
    let description: String
    let enumName: [String]

    enum CodingKeys: String, CodingKey {
        case type
        case description
        case enumName = "enum"
    }
}
