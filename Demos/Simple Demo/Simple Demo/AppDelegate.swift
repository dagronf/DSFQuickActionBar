//
//  AppDelegate.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Cocoa
import DSFQuickActionBar
//import DSFAppKitBuilder

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!

	@IBOutlet var resultLabel: NSTextField!

	var currentSearch = ""

	lazy var quickActionBar: DSFQuickActionBar = {
		let b = DSFQuickActionBar()
		b.contentSource = self
		b.rowHeight = 48
		return b
	}()

	func applicationDidFinishLaunching(_: Notification) {
		// Insert code here to initialize your application

		//DSFAppKitBuilder.ShowDebuggingOutput = true

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
			parentWindow: self.window,
			placeholderText: "Search Filters",
			searchImage: NSImage(named: "filter-icon")!)
		{
			Swift.print("Quick action bar closed")
		}
	}

	@IBAction func showGlobalQuickActions(_: Any) {
		self.resultLabel.stringValue = ""
		self.quickActionBar.present(
			placeholderText: "Search Filters Globally",
			searchImage: NSImage(named: "NSColorPanel")!,
			width: 800
		) {
			Swift.print("Quick action bar closed")
		}
	}

	var loadingType = 1
	@IBAction func setLoadingType(_ sender: NSButton) {
		self.loadingType = sender.tag
	}

	@objc dynamic var showAllWhenEmpty: Bool = false

}

extension AppDelegate: DSFQuickActionBarContentSource {
	func quickActionBar(_: DSFQuickActionBar, identifiersForSearchTerm searchTerm: String) -> [AnyHashable] {

		// Display ALL items when there's no search term
		if showAllWhenEmpty && searchTerm.isEmpty {
			return AllFilters
				.sorted { a, b in a.userPresenting < b.userPresenting }
		}

		self.currentSearch = searchTerm

		if searchTerm.isEmpty {
			return []
		}

		/// Return the item identifiers for the matching mountains
		let matches = AllFilters
			.filter { $0.userPresenting.localizedCaseInsensitiveContains(searchTerm) }
			.sorted(by: { a, b in a.userPresenting < b.userPresenting })

		return matches
	}

	func quickActionBar(_: DSFQuickActionBar, viewForIdentifier identifier: AnyHashable, searchTerm: String) -> NSView? {
		// Find the item with the specified item identifier
		guard let filter = AllFilters.filter({ $0 as AnyHashable == identifier }).first else {
			return nil
		}
		return cellForFilter(filter: filter)
	}

	func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: AnyHashable) {
		guard let mountain = AllFilters.filter({ $0 as AnyHashable == identifier }).first else {
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
			return DSFAppKitBuilderCell(filter: filter, currentSearch: currentSearch)
		}
		else if self.loadingType == 1 {
			// Load from a XIB
			return XIBResultCell(filter: filter, currentSearch: currentSearch)
		}
		else if self.loadingType == 3 {
			// Load hosted SwiftUI
			if #available(macOS 10.15, *) {
				return SwiftUIResultCell(filter: filter, currentSearch: currentSearch)
			} else {
				// Fallback on earlier versions
			}
		}
		fatalError()
	}
}
