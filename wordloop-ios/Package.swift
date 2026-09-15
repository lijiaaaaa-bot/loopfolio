// swift-tools-version: 6.0
// Why: portable SwiftPM module so the lab can run as its own Debug app, or be copied
// into ~/Projects/wordloop-ios. UI lives in LoopfolioUI; logic is unit-tested without a simulator.

import PackageDescription

let package = Package(
    name: "wordloop-ios",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LoopfolioUI", targets: ["LoopfolioUI"]),
    ],
    targets: [
        .target(name: "LoopfolioUI", path: "Sources/LoopfolioUI"),
        .testTarget(
            name: "LoopfolioUITests",
            dependencies: ["LoopfolioUI"],
            path: "Tests/LoopfolioUITests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
