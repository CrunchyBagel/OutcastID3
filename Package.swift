// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OutcastID3",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v9),
        .watchOS(.v4),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "OutcastID3",
            targets: ["OutcastID3"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OutcastID3",
            dependencies: []),
//        .testTarget(
//            name: "OutcastID3Tests",
//            dependencies: ["OutcastID3"]),
    ]
)
