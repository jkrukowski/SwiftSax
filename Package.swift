// swift-tools-version:5.2

import PackageDescription

#if os(Linux) || os(macOS)
let dependencies: [Target.Dependency] = ["Clibxml2"]
#else
let dependencies = []
#endif

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
            dependencies: dependencies,
            linkerSettings: [.linkedLibrary("xml2")]
        ),
        .testTarget(
            name: "SwiftSaxTests",
            dependencies: ["SwiftSax"]
        )
    ]
)
