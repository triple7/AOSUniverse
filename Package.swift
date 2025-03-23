// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AOSUniverse",
    platforms: [
        .iOS("16.1"),
        .macOS("13"),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AOSUniverse",
            targets: ["AOSUniverse"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/marmelroy/Zip.git", branch: "master"),
        .package(url: "https://github.com/triple7/SwiftHorizons.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AOSUniverse",
            dependencies: [
                .product(name: "Zip", package: "Zip"),
                .product(name: "SwiftHorizons", package: "SwiftHorizons"),            ]),
        .testTarget(
            name: "AOSUniverseTests",
            dependencies: ["AOSUniverse"]),
    ]
)
