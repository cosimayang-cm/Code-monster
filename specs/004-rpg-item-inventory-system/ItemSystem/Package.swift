// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ItemSystem",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ItemSystem",
            targets: ["ItemSystem"]),
    ],
    targets: [
        .target(
            name: "ItemSystem",
            dependencies: [],
            path: ".",
            exclude: ["Tests"],
            sources: ["Models", "Services", "Serialization"]),
        .testTarget(
            name: "ItemSystemTests",
            dependencies: ["ItemSystem"],
            path: "Tests"),
    ]
)
