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
		filters__.showAllIfEmpty = showAllWhenEmpty
		self.quickActionBar.present(
			parentWindow: self.window,
			placeholderText: "Search Filters",
			searchImage: NSImage(named: "filter-icon")!,
			width: min(800, max(500, self.window.frame.width + 50))
		) {
			Swift.print("Quick action bar closed")
		}
	}

	@IBAction func showGlobalQuickActions(_: Any) {
		filters__.showAllIfEmpty = showAllWhenEmpty

		self.resultLabel.stringValue = ""
		self.quickActionBar.present(
			placeholderText: "Search Filters Globally",
			searchImage: NSImage(named: "NSColorPanel")!
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
	func quickActionBar(_: DSFQuickActionBar, itemsForSearchTerm searchTerm: String) -> [AnyHashable] {
		self.currentSearch = searchTerm
		return filters__.search(searchTerm)
	}

	func quickActionBar(_: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView? {
		// Find the item with the specified item identifier
		guard let filter = item as? Filter else { fatalError() }
		return cellForFilter(filter: filter)
	}

	func quickActionBar(_: DSFQuickActionBar, didSelectItem item: AnyHashable) {
		guard let filter = item as? Filter else { fatalError() }
		self.resultLabel.stringValue = "Quick Action Bar selected '\(filter.name)'"
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
