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
    targets: [
        .target(
            name: "CrewmateCore"
        ),
        .testTarget(
            name: "CrewmateCoreTests",
            dependencies: ["CrewmateCore"]
        ),
    ]
)
