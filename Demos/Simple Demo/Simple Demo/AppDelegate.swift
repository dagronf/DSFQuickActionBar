//
//  AppDelegate.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Cocoa
import DSFQuickActionBar

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!

	@IBOutlet var resultLabel: NSTextField!

	var currentSearch = ""

	lazy var quickActionBar: DSFQuickActionBar = {
		let b = DSFQuickActionBar()
		b.contentSource = self
		return b
	}()

	func applicationDidFinishLaunching(_: Notification) {
		// Insert code here to initialize your application
		self.resultLabel.stringValue = ""
	}

	func applicationWillTerminate(_: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
		return true
	}

	@IBAction func showQuickActions(_: Any) {
		self.resultLabel.stringValue = ""
		self.quickActionBar.present(
			in: self.window,
			placeholderText: "Search Filters",
			searchImage: NSImage(named: "filter-icon")!
		)
	}

	@IBAction func showGlobalQuickActions(_: Any) {
		self.resultLabel.stringValue = ""
		self.quickActionBar.presentOnMainScreen(
			placeholderText: "Search Filters Globally",
			width: 800
		)
	}

	var loadingType = 1
	@IBAction func setLoadingType(_ sender: NSButton) {
		self.loadingType = sender.tag
	}

	@objc dynamic var showAllWhenEmpty: Bool = false

}

extension AppDelegate: DSFQuickActionBarContentSource {
	func quickActionBar(_: DSFQuickActionBar, identifiersForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {

		// Display ALL items when there's no search term
		if showAllWhenEmpty && term.isEmpty {
			return AllFilters
				.sorted { a, b in a.userPresenting < b.userPresenting }
				.map { $0.id }
		}

		self.currentSearch = term

		if term.isEmpty {
			return []
		}

		/// Return the item identifiers for the matching mountains
		let matches = AllFilters
			.filter { $0.userPresenting.localizedCaseInsensitiveContains(term) }
			.sorted(by: { a, b in a.userPresenting < b.userPresenting })
			.map { $0.id }

		return matches
	}

	func quickActionBar(_: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
		// Find the item with the specified item identifier
		guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
			return nil
		}
		return cellForFilter(filter: filter)
	}

	func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let mountain = AllFilters.filter({ $0.id == identifier }).first else {
			fatalError()
		}
		self.resultLabel.stringValue = "Quick Action Bar selected '\(mountain.name)'"
	}

	func quickActionBarDidCancel(_: DSFQuickActionBar) {
		self.resultLabel.stringValue = "Quick Action Bar cancelled"
	}
}

extension AppDelegate {
	private func cellForFilter(filter: Filter) -> NSView {
		if self.loadingType == 2 {
			// Load raw Appkit
			return DSFAppKitBuilderView(filter: filter, currentSearch: currentSearch)
		}
		else if self.loadingType == 1 {
			// Load from a XIB
			return XIBResultCell(filter: filter, currentSearch: currentSearch)
		}
		else if self.loadingType == 3 {
			// Load hosted SwiftUI
			return SwiftUIResultCell(filter: filter, currentSearch: currentSearch)
		}
		fatalError()
	}
}
