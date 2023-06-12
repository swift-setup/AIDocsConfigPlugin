// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIDocsConfigPlugin",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AIDocsConfigPlugin",
            type: .dynamic,
            targets: ["AIDocsConfigPlugin"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-setup/PluginInterface", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/swift-setup/SwiftUIJsonSchemaForm", branch: "main"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Flight-School/AnyCodable", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AIDocsConfigPlugin",
            dependencies: [
                .product(name: "PluginInterface", package: "PluginInterface"),
                .product(name: "SwiftUIJsonSchemaForm", package: "SwiftUIJsonSchemaForm"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "AnyCodable", package: "AnyCodable")

            ]),
        .testTarget(
            name: "AIDocsConfigPluginTests",
            dependencies: ["AIDocsConfigPlugin"])
    ])
