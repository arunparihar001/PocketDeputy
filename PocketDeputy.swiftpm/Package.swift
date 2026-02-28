// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PocketDeputy",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "PocketDeputy",
            targets: ["AppModule"],
            bundleIdentifier: "com.arunparihar.pocketdeputy",
            teamIdentifier: "", // keep empty for Playgrounds
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .lockShield),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [.phone, .pad],
            supportedInterfaceOrientations: [
                .portrait, .landscapeLeft, .landscapeRight
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources/AppModule",
            resources: []
        )
    ]
)
