// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftsax",
    products: [
        .library(
            name: "SwiftSax",
            targets: ["SwiftSax"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftSax",
            dependencies: ["Logging"],
            linkerSettings: [.linkedLibrary("xml2")]
        ),
        .testTarget(
            name: "SwiftSaxTests",
            dependencies: ["SwiftSax"]
        )
    ]
)
