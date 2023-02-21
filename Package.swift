// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TLIndexPathTools",
    platforms: [
        .iOS("8.0")
    ],
    products: [
        .library(name: "TLIndexPathTools", targets: ["TLIndexPathTools"])
    ],
    targets: [
        .target(
            name: "TLIndexPathTools",
            path: "TLIndexPathTools",
            exclude: [
                "Info.plist",
            ],
            publicHeadersPath: "TLIndexPathTools"
        )
    ]
)
