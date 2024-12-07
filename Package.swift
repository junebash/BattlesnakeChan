// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BattlesnakeChan",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-url-routing",
            .upToNextMajor(from: Version(0, 1, 0))
        ),
        .package(
            url: "https://github.com/hummingbird-project/hummingbird.git",
            .upToNextMajor(from: Version(2, 0, 0))
        )
    ],
    targets: [
        .executableTarget(
            name: "BattlesnakeChan",
            dependencies: [
                .product(name: "URLRouting", package: "swift-url-routing"),
                .product(name: "Hummingbird", package: "hummingbird")
            ]
        ),
    ]
)
