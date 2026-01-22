// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Clips",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "Clips",
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
