// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftSDUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SwiftSDUI", targets: ["SwiftSDUI"])
    ],
    targets: [
        .target(
            name: "SwiftSDUI",
            path: "Source",
            exclude: [],
            sources: nil,
            resources: [],
            publicHeadersPath: nil
        )
    ]
)

