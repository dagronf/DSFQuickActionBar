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

	lazy var quickActionBar: DSFQuickActionBar = {
		let b = DSFQuickActionBar()
		b.delegate = self
		return b
	}()

	private let allMountains: [DSFQuickActionBar.CompletionIdentity] = mountainsRawData.components(separatedBy: .newlines).map { line in
		 let name = line.components(separatedBy: ",")[0]
		 return DSFQuickActionBar.CompletionIdentity(matchString: name)
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

	@IBAction func showQuickActions(_ sender: Any) {
		quickActionBar.present(in: self.window, placeholderText: "Search Mountains")
	}


}

extension AppDelegate: DSFQuickActionBarDelegate {
	func quickBarCompletions(for quickActionBar: DSFQuickActionBar) -> [DSFQuickActionBar.CompletionIdentity] {
		return allMountains
	}
	
	func quickBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier: DSFQuickActionBar.CompletionIdentity) -> NSView? {
		let item = MountainCellQuickView()
		item.actionName.stringValue = viewForIdentifier.matchString
		item.actionDescription.stringValue = "\(viewForIdentifier.matchString) description"
		return item
	}
	
	func quickBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: DSFQuickActionBar.CompletionIdentity) {
		Swift.print("Quick Bar did select '\(item.matchString)'")
	}

	func quickBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		Swift.print("Quick Bar did cancel")
	}
	
	
}
