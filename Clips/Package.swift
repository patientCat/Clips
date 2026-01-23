// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Clips",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.1.9")
    ],
    targets: [
        .executableTarget(
            name: "Clips",
            dependencies: ["SwiftUIX"],
            path: "Sources",
            sources: [
                "App",
                "Models",
                "Services",
                "Views",
                "Theme"
            ]
        ),
    ]
)
