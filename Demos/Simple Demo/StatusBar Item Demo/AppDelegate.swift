//
//  AppDelegate.swift
//  StatusBar Item Demo
//
//  Created by Darren Ford on 12/12/2022.
//

import Cocoa
import DSFQuickActionBar

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	// The image to display in the menu status bar
	private let statusImage = NSImage(
		systemSymbolName: "globe.asia.australia.fill",
		accessibilityDescription: "globe.asia.australia.fill"
	)

	// The image to display in the search bar
	private let searchImage = NSImage(
		systemSymbolName: "globe.asia.australia",
		accessibilityDescription: "globe.asia.australia"
	)

	// The status item
	private lazy var statusItem = {
		let s = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		if let button = s.button {
			button.image = statusImage
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
			button.action = #selector(showQuickActionBar(_:))
		}
		return s
	}()

	// The font to use in the results views
	private let resultFont = NSFont.systemFont(ofSize: 26, weight: .regular)

	// Search bar
	lazy var quickActionBar: DSFQuickActionBar = {
		let b = DSFQuickActionBar()
		b.contentSource = self
		return b
	}()

	// The countries built from the raw text file
	private lazy var countries: [(countryCode: String, flag: String, name: String, flattened: String)] = {
		var result: [(countryCode: String, flag: String, name: String, flattened: String)] = []
		let url = Bundle.main.url(forResource: "countries", withExtension: "txt")!
		let text = try! String(contentsOf: url)
		text.enumerateLines { line, stop in
			let i = line.components(separatedBy: "|")
			result.append((i[0], i[1], i[2], i[3]))
		}
		return result
	}()

	func applicationDidFinishLaunching(_ aNotification: Notification) {

		Swift.print("""
			Demonstrates using a quick action bar directly from the status bar (without a primary UI)
			- Right-click the status bar item to quit.\n
			""")

		// Create the status item
		_ = statusItem
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}

// MARK: - DSFQuickActionBar actions

extension AppDelegate {
	@objc func showQuickActionBar(_ sender: Any?) {

		let event = NSApp.currentEvent!
		if event.type ==  NSEvent.EventType.rightMouseUp {
			let menu = NSMenu(title: "Status Bar Menu")
			menu.addItem(
				withTitle: "Quit",
				action: #selector(NSApp.terminate(_:)),
				keyEquivalent: "")

			NSMenu.popUpContextMenu(menu, with: event, for: statusItem.button!)
			return
		}

		// Show
		self.quickActionBar.present(
			parentWindow: nil,
			placeholderText: "Search countries…",
			searchImage: searchImage,
			showKeyboardShortcuts: true
		)
	}
}

// MARK: - DSFQuickActionBar content source

extension AppDelegate: DSFQuickActionBarContentSource {
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTermTask task: DSFQuickActionBar.SearchTask) {
		if task.searchTerm == "" {
			// We want to show all the results if there's no search term
			task.complete(with: (0 ..< countries.count).map { $0 })
			return
		}

		// Perform the search
		let c = countries.enumerated().filter {
			$0.1.flattened.localizedCaseInsensitiveContains(task.searchTerm)
		}

		// Return the indexes of the matching items
		task.complete(with: c.map { $0.0 })
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView? {
		let cdata = countries[item as! Int]
		let t = NSTextField(labelWithString: "\(cdata.flag)  \(cdata.name)")
		t.translatesAutoresizingMaskIntoConstraints = false
		t.font = resultFont
		return t
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didActivateItem item: AnyHashable) {
		let country = countries[item as! Int].name
		//Swift.print("Quick Action Bar: Selected country '\(country)'")

		// Open the country in Apple Maps
		// https://itnext.io/apple-maps-url-schemes-e1d3ac7340af

		let wrapped = country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let url = URL(string: "maps://?address=\(wrapped)")!
		NSWorkspace.shared.open(url)
	}

	func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		Swift.print("Quick Action Bar: cancelled!")
	}
}
