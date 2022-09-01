//
//  DSFQuickActionBar.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import AppKit

/// A spotlight inspired floating action bar
public class DSFQuickActionBar {
	/// The default width for a quick action bar.
	public static let DefaultWidth: Double = 640

	// The default placeholder text to display in the edit field
	public static let DefaultPlaceholderString: String = "Quick Actions"

	/// The default image to display in the search field
	public static let DefaultImage: NSImage = {
		let image = DSFQuickActionBar.DefaultSearchImage()
		image.isTemplate = true
		return image
	}()

	/// The contentSource for the bar
	public weak var contentSource: DSFQuickActionBarContentSource?

	/// If targeting 10.12 or 10.11 then you'll need to specify a row height (they don't support automaticTableRowHeights)
	public var rowHeight: CGFloat = 36

	/// The current search text
	public var currentSearchText: String? {
		quickActionBarWindow?.currentSearchText
	}

	/// Is the quick action bar currently presented on screen?
	public var isPresenting: Bool {
		return self.quickBarController != nil
	}

	/// Create a DSFQuickActionBar instance
	public init() {}

	// MARK: - Private
	internal weak var quickActionBarWindow: DSFQuickActionBar.Window?
	internal var quickBarController: NSWindowController?
	internal var onCloseCallback: (() -> Void)?
	internal var width: CGFloat = DSFQuickActionBar.DefaultWidth
	internal var searchImage: NSImage?
}

public extension DSFQuickActionBar {
	/// Present a DSFQuickActionBar located within the bounds of the provided parent window
	/// - Parameters:
	///   - parentWindow: the window to center the quick action bar in, or nil to center on screen
	///   - placeholderText: the placeholder text to display in the search field
	///   - searchImage: the image to use as the search image. If nil, uses the default image
	///   - initialSearchText: the text to initially populate the search field with
	///   - width: the width of the quick action bar to display
	///   - didClose: A callback to indicate that the quick action bar has closed
	func present(
		parentWindow: NSWindow? = nil,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = nil,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth,
		didClose: (() -> Void)? = nil
	) {
		self.width = width
		self.searchImage = {
			if let searchImage = searchImage {
				// Scale the image to the required size
				let r = searchImage.scaleImageProportionally(to: 64)
				r?.isTemplate = searchImage.isTemplate
				return r
			}
			else {
				return Self.DefaultImage
			}
		}()
		self.onCloseCallback = didClose

		let originRect: CGRect
		if let parentWindow = parentWindow {
			originRect = parentWindow.frame
		}
		else if let screenFrame = NSScreen.main?.frame {
			originRect = screenFrame
		}
		else {
			return
		}

		let w2: CGFloat = width // the width of the action bar
		let h2: CGFloat = 100 // just a default height

		let x2 = originRect.origin.x + ((originRect.width - w2) / 2.0)
		let y2 = originRect.origin.y + ((originRect.height - h2) / 1.3)
		let posRect = CGRect(x: x2, y: y2, width: w2, height: h2)

		let quickBarWindow = DSFQuickActionBar.Window()
		self.quickBarController = NSWindowController(window: quickBarWindow)
		self.quickActionBarWindow = quickBarWindow

		quickBarWindow.quickActionBar = self
		quickBarWindow.setFrame(posRect, display: true)
		quickBarWindow.setup(parentWindow: parentWindow, initialSearchText: initialSearchText)

		quickBarWindow.placeholderText = placeholderText ?? ""

		quickBarWindow.didDetectClose = { [weak self] in
			self?.quickBarController = nil
			self?.onCloseCallback?()
		}

		quickBarWindow.makeKeyAndOrderFront(self)
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
