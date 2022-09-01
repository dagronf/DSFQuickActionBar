// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFQuickActionBar",
	platforms: [
		.macOS(.v10_11),
	],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "DSFQuickActionBar",
			type: .static,
			targets: ["DSFQuickActionBar"]),
		.library(
			name: "DSFQuickActionBarDynamic",
			type: .dynamic,
			targets: ["DSFQuickActionBar"]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "3.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "DSFQuickActionBar",
			dependencies: ["DSFAppearanceManager"]),
		.testTarget(
			name: "DSFQuickActionBarTests",
			dependencies: ["DSFQuickActionBar"]),
	]
)
