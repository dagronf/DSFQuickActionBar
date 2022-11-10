//
//  QuickActionBar.swift
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

import Foundation
import SwiftUI

#if os(macOS) && canImport(SwiftUI)

/// The location indicating the presentation location for the quick access bar
public enum QuickActionBarLocation {
	/// Locate the quick access bar centered within the parent window
	case window
	/// Locate the quick access bar centered on the screen (ala Spotlight)
	case screen
}

/// A SwiftUI Quick Action Bar
///
/// **`IdentifierType`** is the type of object that is being used to uniquely identify a result from a search.
///
/// For example, if you are searching for files, the `IdentifierType` could be `URL`.
///
/// **`RowContentView`** is the type of SwiftUI View that will be used to represent an identifier in the UI
@available(macOS 10.15, *)
public struct QuickActionBar<IdentifierType: Hashable, RowContentView: View>: NSViewRepresentable {

	public typealias ResultItemsForSearchAsyncType = ([IdentifierType]) -> Void
	public typealias ItemsForSearchTermAsyncType = (String, @escaping ResultItemsForSearchAsyncType) -> Void

	/// A view that can display a quick action bar (spotlight-style bar)
	/// - Parameters:
	///   - location: Where to locate the quick action bar. If window, locates the bar over the window containing parent view. If screen, centers on the screen ala Spotlight
	///   - visible: If true, presents the quick action bar on the screen
	///   - barWidth: The width of the presented bar
	///   - showKeyboardShortcuts: display keyboard shortcuts for the first 10 entries
	///   - requiredClickCount: The number of clicks on an item to activate it
	///   - searchTerm: The search term to use, updated when the quick action bar is closed
	///   - selectedItem: The item selected by the user
	///   - placeholderText: The text to display in the quick action bar when the search term is empty
	///   - searchImage: Provide an image to display on the left of the search term
	///   - itemsForSearchTerm: A block which returns the identifiers for the specified search term.
	///   - isItemSelectable: Return false to mark an item as 'not selectable' (eg. if the item is a separator). By default, you can always select an item
	///   - itemSelected: Called when an item is selected in the results
	///   - viewForItem: A block which returns the View content (of type `RowContentView`) to display for the specified identifier
	public init(
		location: QuickActionBarLocation = .screen,
		visible: Binding<Bool>,
		barWidth: Double? = nil,
		showKeyboardShortcuts: Bool = false,
		requiredClickCount: DSFQuickActionBar.RequiredClickCount = .double,
		searchTerm: Binding<String> = .constant(""),
		selectedItem: Binding<IdentifierType?>,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = nil,
		itemsForSearchTerm: @escaping ItemsForSearchTermAsyncType,
		isItemSelectable: ((IdentifierType) -> Bool)? = nil,
		itemSelected: ((IdentifierType) -> Void)? = nil,
		viewForItem: @escaping (_ identifier: IdentifierType, _ searchTerm: String) -> RowContentView?
	) {
		self._visible = visible
		self.searchImage = searchImage
		self.barWidth = barWidth
		self.showKeyboardShortcuts = showKeyboardShortcuts
		self.requiredClickCount = requiredClickCount
		self.location = location
		self.placeholderText = placeholderText
		self._currentSearchText = searchTerm
		self._selectedItem = selectedItem
		self._isItemSelectable = isItemSelectable
		self._itemSelected = itemSelected
		self._itemsForSearchTerm = itemsForSearchTerm
		self._rowContent = viewForItem
	}

	// private

	private let location: QuickActionBarLocation
	private let placeholderText: String?
	private let showKeyboardShortcuts: Bool
	private let requiredClickCount: DSFQuickActionBar.RequiredClickCount
	private let _rowContent: (IdentifierType, String) -> RowContentView?
	private let _itemsForSearchTerm: ItemsForSearchTermAsyncType
	private let _isItemSelectable: ((IdentifierType) -> Bool)?
	private let _itemSelected: ((IdentifierType) -> Void)?
	private let searchImage: NSImage?
	@Binding var visible: Bool
	@Binding var selectedItem: IdentifierType?
	@Binding var currentSearchText: String

	private let barWidth: Double?
}

@available(macOS 10.15, *)
public extension QuickActionBar {
	func makeCoordinator() -> Coordinator {
		Coordinator(
			isVisible: self.$visible,
			selectedItem: self.$selectedItem,
			currentSearchText: self.$currentSearchText,
			requiredClickCount: self.requiredClickCount,
			itemsForSearchTerm: self._itemsForSearchTerm,
			isItemSelectable: self._isItemSelectable,
			itemSelected: self._itemSelected,
			rowContent: self._rowContent
		)
	}

	func makeNSView(context: Context) -> NSView {
		let c = NSView()
		c.translatesAutoresizingMaskIntoConstraints = false
		c.widthAnchor.constraint(equalToConstant: 0).isActive = true
		c.heightAnchor.constraint(equalToConstant: 0).isActive = true
		return c
	}

	func updateNSView(_ nsView: NSView, context: Context) {
		// Grab the nsview object
		let quickAction = context.coordinator.quickActionBar

		if self.visible == false, quickAction.isPresenting == false {
			return
		}

		if self.visible {
			if quickAction.isPresenting {
				// We are already visible
				return
			}

			// Set the required click count
			quickAction.requiredClickCount = requiredClickCount

			// We need to present the quick action bar
			quickAction.present(
				parentWindow: (self.location == .window) ? nsView.window : nil,
				placeholderText: self.placeholderText,
				searchImage: self.searchImage ?? DSFQuickActionBar.DefaultImage,
				initialSearchText: self.currentSearchText,
				width: self.barWidth ?? DSFQuickActionBar.DefaultWidth,
				showKeyboardShortcuts: self.showKeyboardShortcuts,
				didClose: {
					// Make sure we close the quick action var
					self.visible = false
				}
			)
		}
		else {
			// We _were_ visible, but we now want to close it
			DispatchQueue.main.async {
				quickAction.cancel()
			}
		}
	}

	typealias NSViewType = NSView
}

@available(macOS 10.15, *)
public extension QuickActionBar {
	class Coordinator: NSObject, DSFQuickActionBarContentSource {
		// Use the coordinator to hold on to the AppKit ui object
		let quickActionBar = DSFQuickActionBar()

		private var itemsForSearchTerm: ItemsForSearchTermAsyncType
		private let isItemSelectable: ((IdentifierType) -> Bool)?
		private let itemSelected: ((IdentifierType) -> Void)?
		private let rowContent: (IdentifierType, String) -> RowContentView?


		@Binding var isVisible: Bool
		@Binding var selectedItem: IdentifierType?
		@Binding var currentSearchText: String

		init(
			isVisible: Binding<Bool>,
			selectedItem: Binding<IdentifierType?>,
			currentSearchText: Binding<String>,
			requiredClickCount: DSFQuickActionBar.RequiredClickCount,
			itemsForSearchTerm: @escaping ItemsForSearchTermAsyncType,
			isItemSelectable: ((IdentifierType) -> Bool)?,
			itemSelected: ((IdentifierType) -> Void)?,
			rowContent: @escaping (IdentifierType, String) -> RowContentView?
		) {
			self._isVisible = isVisible
			self._selectedItem = selectedItem
			self._currentSearchText = currentSearchText
			self.isItemSelectable = isItemSelectable
			self.itemsForSearchTerm = itemsForSearchTerm
			self.itemSelected = itemSelected
			self.rowContent = rowContent
			super.init()

			self.quickActionBar.contentSource = self
		}

		public func quickActionBar(
			_ quickActionBar: DSFQuickActionBar,
			itemsForSearchTerm searchTerm: String,
			resultsCallback: @escaping ([AnyHashable]) -> Void)
		{
			self.itemsForSearchTerm(searchTerm, resultsCallback)
			//resultsCallback(self.itemsForSearchTerm(searchTerm))
		}

		public func quickActionBar(
			_ quickActionBar: DSFQuickActionBar,
			didActivateItem item: AnyHashable
		) {
			// Update the selection
			self.selectedItem = item as? IdentifierType

			// Reflect the term that was searched for
			self.currentSearchText = quickActionBar.currentSearchText ?? ""

			// Tell the window to go away
			self.isVisible = false
		}

		public func quickActionBar(_ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable) -> Bool {
			guard let item = item as? IdentifierType else { fatalError() }
			return self.isItemSelectable?(item) ?? true
		}

		public func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: AnyHashable) {
			guard let item = item as? IdentifierType else { fatalError() }
			self.itemSelected?(item)
		}

		public func quickActionBar(
			_ quickActionBar: DSFQuickActionBar,
			viewForItem item: AnyHashable,
			searchTerm: String
		) -> NSView? {
			guard let item = item as? IdentifierType else {
				fatalError()
			}
			if let view = self.rowContent(item, searchTerm) {
				return NSHostingView<RowContentView>(rootView: view)
			}
			return nil
		}

		public func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
			self.isVisible = false
		}
	}
}

#endif
