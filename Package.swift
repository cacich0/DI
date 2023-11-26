// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DI",
    products: [
        .library(
            name: "DI",
            targets: ["DI"]
        ),
    ],
    targets: [
        .target(
            name: "DI"
        ),
        .testTarget(
            name: "SimpleTests",
            dependencies: ["DI"]
        )
    ]
)
