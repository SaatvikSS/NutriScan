// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "NutriScan",
    platforms: [
        .iOS(.v14) // Specify the minimum iOS version
    ],
    products: [
        .library(
            name: "NutriScan",
            targets: ["NutriScan"]),
    ],
    dependencies: [
        // Add any dependencies your project requires here
    ],
    targets: [
        .target(
            name: "NutriScan",
            dependencies: [],
            path: "NutriScan_v2" // Adjust this path based on your project structure
        ),
        .testTarget(
            name: "NutriScanTests",
            dependencies: ["NutriScan"],
            path: "Tests" // Create a Tests directory for your unit tests
// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NutriScan",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "NutriScan",
            targets: ["NutriScan"],
            bundleIdentifier: "com.yourname.NutriScan",
            teamIdentifier: "YOUR_TEAM_ID",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .leaf),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            infoPlist: [
                "NSCameraUsageDescription": "NutriScan needs camera access to scan barcodes and ingredient labels.",
                "NSPhotoLibraryUsageDescription": "NutriScan needs photo library access to scan ingredient labels from photos."
            ]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NutriScan",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
) 