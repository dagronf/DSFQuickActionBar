//
//  AppDelegate.swift
//  Doco Demo
//
//  Created by Darren Ford on 1/9/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		Swift.print("""
		Demonstrates using a quick action bar synchronously from AppKit.
		""")
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}
