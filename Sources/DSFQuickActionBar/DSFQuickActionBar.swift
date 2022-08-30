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

/// A spotlight inspired floating action bar
public class DSFQuickActionBar {

	/// A unique identifier for a actionable item.
	///
	/// Each available item to be presented in the results must be able to be identified using an ItemIdentifier
	public typealias ItemIdentifier = UUID

	/// The default width for the quick action bar
	public static let DefaultWidth: CGFloat = 500.0

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

	/// Create a DSFQuickActionBar instance
	public init() {}

	// MARK: - Private
	internal weak var quickActionBarWindow: DSFQuickActionBar.Window?
	internal var quickBarController: DSFQuickActionBar.WindowController?

	internal var _onClose: (() -> Void)?

	internal var width: CGFloat = 100
	internal var searchImage: NSImage?

	public var isPresenting: Bool {
		return self.quickBarController != nil
	}
}

public extension DSFQuickActionBar {
	/// Present a DSFQuickActionBar located within the bounds of the provided parent window
	/// - Parameters:
	///   - screenPosition: the screen frame to center the bar in
	///   - placeholderText: the placeholder text to display in the search field
	///   - searchImage: the image to use as the search image. If nil, no search field image is displayed
	///   - initialSearchText: the text to initially populate the search field with
	///   - width: the width of the quick action bar to display
	func present(
		screenPosition: CGRect,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = DSFQuickActionBar.DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth,
		didClose: (() -> Void)? = nil
	) {
		self.present(
			in: screenPosition,
			parentWindow: nil,
			placeholderText: placeholderText,
			searchImage: searchImage,
			initialSearchText: initialSearchText,
			width: width,
			didClose: didClose
		)
	}

	/// Present a DSFQuickActionBar located within the bounds of the provided parent window
	/// - Parameters:
	///   - parent: the window to center the quick action bar in
	///   - placeholderText: the placeholder text to display in the search field
	///   - searchImage: the image to use as the search image. If nil, no search field image is displayed
	///   - initialSearchText: the text to initially populate the search field with
	///   - width: the width of the quick action bar to display
	func present(
		in parent: NSWindow,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = DSFQuickActionBar.DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth,
		didClose: (() -> Void)? = nil
	) {
		self.present(
			in: parent.frame,
			parentWindow: parent,
			placeholderText: placeholderText,
			searchImage: searchImage,
			initialSearchText: initialSearchText,
			width: width,
			didClose: didClose
		)
	}
	
	/// Presents a DSFQuickActionBar on the main screen
	/// - Parameters:
	///   - placeholderText: the placeholder text to display in the search field
	///   - searchImage: the image to use as the search image. If nil, no search field image is displayed
	///   - initialSearchText: the text to initially populate the search field with
	///   - width: the width of the quick action bar to display
	func presentOnMainScreen(
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth,
		didClose: (() -> Void)? = nil
	) {
		guard let rect = NSScreen.main?.frame else { return }
		self.present(
			in: rect,
			parentWindow: nil,
			placeholderText: placeholderText,
			searchImage: searchImage,
			initialSearchText: initialSearchText,
			width: width,
			didClose: didClose
		)
	}
}

extension DSFQuickActionBar {
	private func present(
		in originRect: CGRect,
		parentWindow: NSWindow?,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth,
		didClose: (() -> Void)? = nil
	) {
		self.width = width
		self.searchImage = searchImage
		self._onClose = didClose

		let w2: CGFloat = width // the width of the action bar
		let h2: CGFloat = 100 // just a default height

		let x2 = originRect.origin.x + ((originRect.width - w2) / 2.0)
		let y2 = originRect.origin.y + ((originRect.height - h2) / 1.3)
		let posRect = CGRect(x: x2, y: y2, width: w2, height: h2)

		let quickBarWindow = DSFQuickActionBar.Window()
		self.quickBarController = WindowController(window: quickBarWindow)
		self.quickActionBarWindow = quickBarWindow

		quickBarWindow.quickActionBar = self
		quickBarWindow.setFrame(posRect, display: true)
		quickBarWindow.setup(parentWindow: parentWindow, initialSearchText: initialSearchText)

		quickBarWindow.placeholderText = placeholderText ?? ""

		self.quickBarController = WindowController(window: quickBarWindow)

		quickBarWindow.startDetectLostFocus { [weak self] in
			self?.quickBarController = nil
			self?._onClose?()
		}

		quickBarWindow.makeKeyAndOrderFront(self)
	}

	private func present(
		at screenPosition: CGRect,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = DefaultImage,
		initialSearchText: String? = nil,
		width: CGFloat = DSFQuickActionBar.DefaultWidth,
		didClose: (() -> Void)? = nil
	) {
		self.width = width
		self.searchImage = searchImage
		self._onClose = didClose

		let w2: CGFloat = width // the width of the action bar
		let h2: CGFloat = 100 // just a default height

		let x2 = screenPosition.origin.x + ((screenPosition.width - w2) / 2.0)
		let y2 = screenPosition.origin.y + ((screenPosition.height - h2) / 1.3)
		let posRect = CGRect(x: x2, y: y2, width: w2, height: h2)

		let quickBarWindow = DSFQuickActionBar.Window()
		self.quickBarController = WindowController(window: quickBarWindow)
		self.quickActionBarWindow = quickBarWindow

		quickBarWindow.quickActionBar = self
		quickBarWindow.setFrame(posRect, display: true)
		quickBarWindow.setup(parentWindow: nil, initialSearchText: initialSearchText)
		//quickBarWindow.makeKey()

		quickBarWindow.placeholderText = placeholderText ?? ""

		quickBarWindow.makeKeyAndOrderFront(self)
		quickBarWindow.startDetectLostFocus { [weak self] in
			self?.quickBarController = nil
			self?._onClose?()
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
