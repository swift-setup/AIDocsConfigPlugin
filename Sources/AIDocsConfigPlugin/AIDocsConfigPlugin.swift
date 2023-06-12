import PluginInterface
import SwiftUI

struct AIDocsConfigPlugin: PluginInterfaceProtocol {
    var manifest: ProjectManifest = .init(displayName: "AIDocsConfigPlugin", bundleIdentifier: "com.sirily11.config.aidocs", author: "sirily11", shortDescription: "Configuration Plugin for AIDocsSearch Server", repository: "https://github.com/swift-setup/AIDocsConfigPlugin", keywords: [], systemImageName: "doc.text.fill")

    let storeUtils: StoreUtilsProtocol
    let panelUtils: NSPanelUtilsProtocol

    var id = UUID()

    var view: some View {
        HomePage(panelUtils: panelUtils, storeUtils: storeUtils, plugin: self)
    }

    var settings: some View {
        SettingsView(storeUtils: storeUtils, plugin: self)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(AIDocsConfigPluginBuilder()).toOpaque()
}

public final class AIDocsConfigPluginBuilder: PluginBuilder {
    override public func build(fileUtils: FileUtilsProtocol, nsPanelUtils: NSPanelUtilsProtocol, storeUtils: StoreUtilsProtocol) -> any PluginInterfaceProtocol {
        AIDocsConfigPlugin(storeUtils: storeUtils, panelUtils: nsPanelUtils)
    }
}
