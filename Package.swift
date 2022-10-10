// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "db-query",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "DBQuery", targets: ["DBQuery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "DBQuery", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "SQLKit", package: "sql-kit"),
        ]),
        .testTarget(name: "DBQueryTests", dependencies: [
            .target(name: "DBQuery"),
        ]),
    ]
)
