// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ObservableWebSocketClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ObservableWebSocketClient",
            targets: ["ObservableWebSocketClient"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/thatfactory/toolbox.git",
            from: "0.1.0"
        )
    ],
    targets: [
        .target(
            name: "ObservableWebSocketClient",
            dependencies: [
                .product(
                    name: "Toolbox",
                    package: "toolbox"
                )
            ]
        ),
        .testTarget(
            name: "ObservableWebSocketClientTests",
            dependencies: ["ObservableWebSocketClient"]
        )
    ]
)
