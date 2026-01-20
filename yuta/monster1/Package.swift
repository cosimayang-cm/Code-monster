// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "FeatureToggleCar",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "FeatureToggleCar", targets: ["FeatureToggleCar"]),
    ],
    targets: [
        .target(name: "FeatureToggleCar", path: "Sources"),
        .testTarget(name: "FeatureToggleCarTests", dependencies: ["FeatureToggleCar"], path: "Tests"),
    ]
)
