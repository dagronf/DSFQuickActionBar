//
//  AppDelegate.swift
//  FauxSpotlight
//
//  Created by Darren Ford on 10/11/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		Swift.print("""
		A fake spotlight-style quick action bar that uses async `NSMetadataQuery` calls to asynchronously return results
		* Demonstrates retrieving results asynchronously
		""")
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}

