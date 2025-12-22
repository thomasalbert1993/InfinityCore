// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrewmateCore",
    platforms: [
        .iOS(.v12),
        .macOS(.v11),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: "CrewmateCore",
            targets: ["CrewmateCore"]
        ),
    ],
    dependencies: [
//        .package(url: "https://github.com/attaswift/BigInt.git", from: "6.1.0")
    ],
    targets: [
        .target(
            name: "CrewmateCore",
            dependencies: [
//                .product(name: "BigInt", package: "BigInt"),
            ]
        ),
        .testTarget(
            name: "CrewmateCoreTests",
            dependencies: ["CrewmateCore"]
        ),
    ]
)
