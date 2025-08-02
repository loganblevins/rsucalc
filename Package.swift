// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "rsucalc",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RSUCalculatorCore",
            targets: ["RSUCalculatorCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        // Shared core library with business logic
        .target(
            name: "RSUCalculatorCore",
            dependencies: []
        ),
        
        // CLI executable
        .executableTarget(
            name: "rsucalc-cli",
            dependencies: [
                "RSUCalculatorCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        
        // Tests
        .testTarget(
            name: "rsucalcTests",
            dependencies: ["RSUCalculatorCore"]
        ),
    ]
) 