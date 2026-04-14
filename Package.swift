// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VibeWatch",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "VibeWatch", path: "Sources"),
    ]
)
