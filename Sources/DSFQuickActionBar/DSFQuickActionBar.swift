//
//  DSFQuickActionBar.swift
//  DSFQuickActionBar
//
//  Created by Darren Ford on 22/7/21
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AppKit

public class DSFQuickActionBar {
	public static let DefaultWidth: CGFloat = 500.0
	public static let DefaultImage = NSImage(named: "NSQuickLookTemplate")

	public weak var delegate: DSFQuickActionBarDelegate?

	internal weak var quickActionBarWindow: DSFQuickActionBar.Window?
	internal var quickBarController: DSFQuickActionBar.WindowController?

	var width: CGFloat = 100
	var placeholderText: String = "Quick Actions"
	var searchImage: NSImage?

	public init() {}
}

public extension DSFQuickActionBar {
	/// Present a DSFQuickActionBar located within the bounds of the provided parent window
	/// - Parameters:
	///   - parent: the window to center the quick action bar in
	///   - placeholderText: the placeholder text to display in the search field
	///   - searchImage: the image to use as the search image
	///   - initialSearchText: the text to initially populate the search field with
	///   - width: the width of the quick action bar to display
	func present(
		in parent: NSWindow,
		placeholderText: String? = nil,
		searchImage: NSImage? = DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth
	) {
		self.present(in: parent.frame,
						 parentWindow: parent,
						 placeholderText: placeholderText,
						 searchImage: searchImage,
						 initialSearchText: initialSearchText,
						 width: width)
	}

	/// Presents a DSFQuickActionBar on the main screen
	/// - Parameters:
	///   - placeholderText: the placeholder text to display in the search field
	///   - searchImage: the image to use as the search image
	///   - initialSearchText: the text to initially populate the search field with
	///   - width: the width of the quick action bar to display
	func presentOnMainScreen(
		placeholderText: String? = nil,
		searchImage: NSImage? = DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth
	) {
		guard let rect = NSScreen.main?.frame else { return }
		self.present(in: rect,
						 parentWindow: nil,
						 placeholderText: placeholderText,
						 searchImage: searchImage,
						 initialSearchText: initialSearchText,
						 width: width)
	}

	private func present(
		in originRect: CGRect,
		parentWindow: NSWindow?,
		placeholderText: String? = nil,
		searchImage: NSImage? = DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth
	) {
		self.width = width
		self.searchImage = searchImage

		if let text = placeholderText {
			self.placeholderText = text
		}

		let w2: CGFloat = width // the width of the action bar
		let h2: CGFloat = 100 // just a default height

		let x2 = originRect.origin.x + ((originRect.width - w2) / 2.0)
		let y2 = originRect.origin.y + ((originRect.height - h2) / 1.3)
		let posRect = CGRect(x: x2, y: y2, width: w2, height: h2)

		let quickBarWindow = DSFQuickActionBar.Window()
		self.quickActionBarWindow = quickBarWindow

		quickBarWindow.quickActionBar = self
		quickBarWindow.setFrame(posRect, display: true)
		quickBarWindow.setup(parentWindow: parentWindow, initialSearchText: initialSearchText)
		quickBarWindow.makeKey()

		self.quickBarController = WindowController(window: quickBarWindow)
		self.quickBarController?.setupWindowListener { [weak self] in
			self?.quickBarController = nil
		}
	}
}

public extension DSFQuickActionBar {
	/// Cancel an active action bar
	func cancel() {
		if let wc = self.quickBarController {
			wc.window?.close()
		}
	}
}
