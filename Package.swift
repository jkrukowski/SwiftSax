// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftSax",
    products: [
        .library(
            name: "SwiftSax",
            targets: ["SwiftSax"]
        )
    ],
    dependencies: [],
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
            dependencies: ["Clibxml2"],
            linkerSettings: [.linkedLibrary("xml2")]
        ),
        .testTarget(
            name: "SwiftSaxTests",
            dependencies: ["SwiftSax"]
        )
    ]
)
