// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TakeARest",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "TakeARest",
            path: "Sources/TakeARest"
        )
    ]
)
