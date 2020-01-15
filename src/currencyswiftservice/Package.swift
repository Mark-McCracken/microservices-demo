// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "currencyswiftservice",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
//        .library(
//            name: "currencyswiftservice",
//            targets: ["currencyswiftservice"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.6"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.11.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "currencyswiftservice",
            dependencies: ["GRPC", "NIO", "NIOHTTP1", "SwiftProtobuf", "CurrencyModel"],
            path: "Sources/currencyswiftservice/Server"),
        .target(
            name: "currencyswiftclient",
            dependencies: ["GRPC", "CurrencyModel"],
            path: "Sources/currencyswiftservice/Client"),
        .target(
          name: "CurrencyModel",
          dependencies: [
            "GRPC",
            "NIO",
            "NIOHTTP1",
            "SwiftProtobuf"
          ],
          path: "Sources/currencyswiftservice/Model")
    ]
)
