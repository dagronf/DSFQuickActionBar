//
//  File.swift
//  
//
//  Created by Darren Ford on 30/8/2022.
//

import Foundation
import AppKit

class EphemeralWindow: NSWindow {
	override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
		//self.setup()
	}

	func startDetectLostFocus(_ completion: @escaping () -> Void) {
		NotificationCenter.default.addObserver(
			forName: NSWindow.didBecomeKeyNotification,
			object: self,
			queue: .main
		) { notification in
			Swift.print("NSWindow.didBecomeKeyNotification")
		}

		NotificationCenter.default.addObserver(
			forName: NSWindow.didResignKeyNotification,
			object: self,
			queue: .main
		) { notification in
			Swift.print("NSWindow.didResignKeyNotification")
			let obj = notification.object as? NSWindow
			obj?.close()
		}

		NotificationCenter.default.addObserver(
			forName: NSWindow.willCloseNotification,
			object: self,
			queue: .main
		) { _ in
			Swift.print("NSWindow.willCloseNotification")
			completion()
		}
	}

	deinit {
		Swift.print("EphemeralWindow: deinit")
	}
}
