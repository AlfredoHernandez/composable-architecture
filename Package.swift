// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComposableArchitecture",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "ComposableArchitecture",
            targets: ["ComposableArchitecture"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "ComposableArchitecture",
            dependencies: []),
        .testTarget(
            name: "ComposableArchitectureTests",
            dependencies: ["ComposableArchitecture"]),
    ]
)
