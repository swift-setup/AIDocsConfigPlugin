//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 6/12/23.
//

import PluginInterface
import SwiftUI
import SwiftUIJsonSchemaForm

struct HomePage: View {
    @StateObject var model: AIDocsConfigModel = .init()
    let panelUtils: NSPanelUtilsProtocol
    let storeUtils: StoreUtilsProtocol
    let plugin: (any PluginInterfaceProtocol)

    var body: some View {
        HStack {
            VStack {
                ConfigView()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
//            Divider()
//            VStack {
//                Text("Hello")
//            }
//            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .environmentObject(model)
        .task {
            model.update(storeUtils: storeUtils, panelUtils: panelUtils, plugin: plugin)
            await model.fetch()
        }
    }
}
