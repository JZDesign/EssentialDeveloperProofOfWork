// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EssentialFeediOS",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "EssentialFeediOS",
            targets: ["EssentialFeediOS"]),
    ],
    dependencies: [ .package(path: "../EssentialFeed") ],
    targets: [
        .target(
            name: "EssentialFeediOS",
            dependencies: [ .product(name: "EssentialFeed", package: "EssentialFeed") ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "EssentialFeediOSTests",
            dependencies: [
                "EssentialFeediOS",
                .product(name: "EssentialFeed", package: "EssentialFeed"),
                .product(name: "EssentialFeedTestHelpers", package: "EssentialFeed")
            ]),
    ]
)
