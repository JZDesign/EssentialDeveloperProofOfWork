// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EssentialFeed",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [
        .library(
            name: "EssentialFeed",
            targets: ["EssentialFeed"]
        ),
        .library(
            name: "EssentialFeedTestHelpers",
            targets: ["EssentialFeedTestHelpers"]),
    ],
    targets: [
        .target(
            name: "EssentialFeed",
            path: "Sources/EssentialFeed",
            resources: [.process("FeedCache/CoreData/Model")]
        ),
        .target(
            name: "EssentialFeedTestHelpers",
            dependencies: [ "EssentialFeed" ],
            path: "Sources/EssentialFeedTestHelpers"
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"]
        ), 
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"]
        ), 
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"]
        ),
    ]
)
