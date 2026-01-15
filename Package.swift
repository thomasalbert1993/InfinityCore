// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrewmateCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v12),
    ],
    products: [
        .library(name: "CrewmateCore", targets: ["CrewmateCore"]),
        .library(name: "CrewmateCoreData", targets: ["CrewmateCoreData"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.7.0")
    ],
    targets: [
        .target(
            name: "CrewmateCore",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
            ]
        ),
        .target(name: "CrewmateCoreData", dependencies: ["CrewmateCore"]),
        .testTarget(name: "CrewmateCoreTests", dependencies: ["CrewmateCore"]),
    ]
)
