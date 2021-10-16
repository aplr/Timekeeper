// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Timekeeper",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Timekeeper",
            targets: ["Timekeeper"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Timekeeper",
            dependencies: []
        ),
        .testTarget(
            name: "TimekeeperTests",
            dependencies: ["Timekeeper"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
