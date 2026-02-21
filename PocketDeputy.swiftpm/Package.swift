// swift-tools-version: 5.9
// Package.swift for PocketDeputy Swift Student Challenge playground.
//
// HOW TO RUN:
//   1. Open PocketDeputy.swiftpm in Xcode (drag the folder or double-click).
//   2. Select an iOS 16+ simulator (e.g., iPhone 15).
//   3. Press ▶ to build and run – no additional setup required.
//
// HOW TO SUBMIT:
//   1. Zip the entire PocketDeputy.swiftpm folder.
//   2. Upload the zip to the Swift Student Challenge submission portal.
//
// WHAT TO PERSONALISE BEFORE SUBMITTING:
//   • Rewrite scenario texts in Scenarios.swift (see TODO comments).
//   • Update the AI tool usage disclosure in AboutView.swift.
//   • Optionally adjust gateway rules in ActionGateway.swift and explain
//     the tradeoffs in your written submission.

import PackageDescription

let package = Package(
    name: "PocketDeputy",
    platforms: [.iOS("16.0")],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources/AppModule"
        )
    ]
)
