// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "L-Tools",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "L-Tools",
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
