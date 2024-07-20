// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "DSFQuickActionBar",
	platforms: [
		.macOS(.v10_13),
	],
	products: [
		.library(name: "DSFQuickActionBar", targets: ["DSFQuickActionBar"]),
		.library(name: "DSFQuickActionBar-static", type: .static, targets: ["DSFQuickActionBar"]),
		.library(name: "DSFQuickActionBar-shared", type: .dynamic, targets: ["DSFQuickActionBar"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", .upToNextMinor(from: "3.5.0")),
	],
	targets: [
		.target(
			name: "DSFQuickActionBar",
			dependencies: ["DSFAppearanceManager"],
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
			]
		),
		.testTarget(
			name: "DSFQuickActionBarTests",
			dependencies: ["DSFQuickActionBar"]
		),
	]
)
