// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UndoRedoSystem",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "UndoRedoSystem",
            targets: ["UndoRedoSystem"]
        ),
        .executable(
            name: "UndoRedoDemo",
            targets: ["UndoRedoDemo"]
        )
    ],
    dependencies: [
        // No external dependencies - using Foundation + Combine only
    ],
    targets: [
        .target(
            name: "UndoRedoSystem",
            dependencies: []
        ),
        .executableTarget(
            name: "UndoRedoDemo",
            dependencies: ["UndoRedoSystem"],
            path: "Sources/UndoRedoDemo",
            exclude: ["README.md"],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        ),
        .testTarget(
            name: "UndoRedoSystemTests",
            dependencies: ["UndoRedoSystem"]
        )
    ]
)
