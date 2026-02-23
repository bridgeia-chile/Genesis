// swift-tools-version: 6.2
// Package manifest for the genesis macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "genesis",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "genesisIPC", targets: ["genesisIPC"]),
        .library(name: "genesisDiscovery", targets: ["genesisDiscovery"]),
        .executable(name: "genesis", targets: ["genesis"]),
        .executable(name: "genesis-mac", targets: ["genesisMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/genesisKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "genesisIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "genesisDiscovery",
            dependencies: [
                .product(name: "genesisKit", package: "genesisKit"),
            ],
            path: "Sources/genesisDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "genesis",
            dependencies: [
                "genesisIPC",
                "genesisDiscovery",
                .product(name: "genesisKit", package: "genesisKit"),
                .product(name: "genesisChatUI", package: "genesisKit"),
                .product(name: "genesisProtocol", package: "genesisKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/genesis.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "genesisMacCLI",
            dependencies: [
                "genesisDiscovery",
                .product(name: "genesisKit", package: "genesisKit"),
                .product(name: "genesisProtocol", package: "genesisKit"),
            ],
            path: "Sources/genesisMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "genesisIPCTests",
            dependencies: [
                "genesisIPC",
                "genesis",
                "genesisDiscovery",
                .product(name: "genesisProtocol", package: "genesisKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
