// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.44.6")
    ],
    targets: [
        .target(
            name: "BuildTools",
            dependencies: ["SwiftFormat"],
            path: "BuildTools"
        )
    ]
)
