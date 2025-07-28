// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "rsucalc",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "rsucalc",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "rsucalcTests",
            dependencies: ["rsucalc"]
        ),
    ]
) 