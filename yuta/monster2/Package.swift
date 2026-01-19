// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PopupResponseChain",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PopupResponseChain",
            targets: ["PopupResponseChain"]
        ),
    ],
    targets: [
        .target(
            name: "PopupResponseChain",
            path: "Sources"
        ),
        .testTarget(
            name: "PopupResponseChainTests",
            dependencies: ["PopupResponseChain"],
            path: "Tests"
        ),
    ]
)
