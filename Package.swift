// swift-tools-version:5.2

import PackageDescription

#if os(Linux)
let dependencies: [Target.Dependency] = ["Clibxml2"]
let linkerSettings: [LinkerSetting]? = nil
#else
let dependencies: [Target.Dependency] = []
let linkerSettings: [LinkerSetting]? = [.linkedLibrary("xml2")]
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
            linkerSettings: linkerSettings
        ),
        .testTarget(
            name: "SwiftSaxTests",
            dependencies: ["SwiftSax"]
        )
    ]
)
