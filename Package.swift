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
        .systemLibrary(
            name: "Clibxml2",
            path: "Modules",
            pkgConfig: "libxml-2.0",
            providers: [
                .brew(["libxml2"]),
                .apt(["libxml2-dev"])
            ]
        ),
        .target(
            name: "SwiftSax",
            dependencies: ["Logging", "Clibxml2"]
        ),
        .testTarget(
            name: "SwiftSaxTests",
            dependencies: ["SwiftSax"]
        )
    ]
)
