// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SwiftCompressor",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_11),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "SwiftCompressor",
            targets: ["SwiftCompressor"]
        )
    ],
    targets: [
        .target(
            name: "SwiftCompressor"
        ),
        .testTarget(
            name: "SwiftCompressorTests",
            dependencies: ["SwiftCompressor"]
        )
    ]
)
