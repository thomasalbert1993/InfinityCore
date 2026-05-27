// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfinityCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v12),
    ],
    products: [
        .library(name: "InfinityCore", targets: ["InfinityCore"]),
        .library(name: "InfinityCoreData", targets: ["InfinityCoreData"]),
        .library(name: "InfinityCorePDF", targets: ["InfinityCorePDF"]),
        .library(name: "InfinityCoreUI", targets: ["InfinityCoreUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.7.0")
    ],
    targets: [
        .target(
            name: "InfinityCore",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
            ]
        ),
        .target(name: "InfinityCoreData", dependencies: ["InfinityCore"]),
        .target(name: "InfinityCorePDF", dependencies: ["InfinityCore"]),
        .target(name: "InfinityCoreUI", dependencies: ["InfinityCore"]),
        .testTarget(name: "InfinityCoreTests", dependencies: ["InfinityCore"]),
        .testTarget(name: "InfinityCoreUITests", dependencies: ["InfinityCoreUI"]),
    ]
)
