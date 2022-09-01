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
@available(macOS 10.15, *)
public final class QuickActionBar<IdentifierType: Hashable, RowContent: View>: NSObject, NSViewRepresentable {
	/// A view that can display a quick action bar (spotlight-style bar)
	/// - Parameters:
	///   - location: Where to locate the quick action bar. If window, locates the bar over the window containing parent view. If screen, centers on the screen ala Spotlight
	///   - visible: If true, presents the quick action bar on the screen
	///   - barWidth: The width of the presented bar
	///   - searchTerm: The search term to use, updated when the quick action bar is closed
	///   - selectedItem: The item selected by the user
	///   - placeholderText: The text to display in the quick action bar when the search term is empty
	///   - identifiersForSearchTerm: A block which returns the identifiers for the specified search term.
	///   - rowContent: A block which returns the View content to display for the specified identifier
	public init(
		location: QuickActionBarLocation = .screen,
		visible: Binding<Bool>,
		barWidth: Double? = nil,
		searchTerm: Binding<String> = .constant(""),
		selectedItem: Binding<IdentifierType?>,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		searchImage: NSImage? = nil,
		identifiersForSearchTerm: @escaping (String) -> [IdentifierType],
		rowContent: @escaping (_ identifier: IdentifierType, _ searchTerm: String) -> RowContent?
	) {
		self._visible = visible
		self.searchImage = searchImage
		self.barWidth = barWidth
		self.location = location
		self.placeholderText = placeholderText
		self._currentSearchText = searchTerm
		self._selectedItem = selectedItem
		self._identifiersForSearchTerm = identifiersForSearchTerm
		self._rowContent = rowContent
		super.init()
	}

	// private

	private let location: QuickActionBarLocation
	private let placeholderText: String?
	private let _rowContent: (IdentifierType, String) -> RowContent?
	private let _identifiersForSearchTerm: (String) -> [IdentifierType]
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
			identifiersForSearchTerm: self._identifiersForSearchTerm,
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

		Swift.print(":: update view -> \(self.visible) : \(quickAction.isPresenting)")

		if self.visible == false, quickAction.isPresenting == false {
			return
		}

		if self.visible {
			if quickAction.isPresenting {
				// We are already visible
				Swift.print(":: Already visible, ignoring")
				return
			}

			// We need to present the quick action bar
			quickAction.present(
				parentWindow: (self.location == .window) ? nsView.window : nil,
				placeholderText: self.placeholderText,
				searchImage: self.searchImage ?? DSFQuickActionBar.DefaultImage,
				initialSearchText: self.currentSearchText,
				width: self.barWidth ?? DSFQuickActionBar.DefaultWidth,
				didClose: {
					// Make sure we close the quick action var
					self.visible = false
					Swift.print(":: quick action bar closed")
				}
			)
		}
		else {
			// We _were_ visible, but we now want to close it
			Swift.print(":: close the quick action bar")

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

		private var identifiersForSearchTerm: (String) -> [IdentifierType]
		private let rowContent: (IdentifierType, String) -> RowContent?

		@Binding var isVisible: Bool
		@Binding var selectedItem: IdentifierType?
		@Binding var currentSearchText: String

		init(
			isVisible: Binding<Bool>,
			selectedItem: Binding<IdentifierType?>,
			currentSearchText: Binding<String>,
			identifiersForSearchTerm: @escaping (String) -> [IdentifierType],
			rowContent: @escaping (IdentifierType, String) -> RowContent?
		) {
			self._isVisible = isVisible
			self._selectedItem = selectedItem
			self._currentSearchText = currentSearchText
			self.identifiersForSearchTerm = identifiersForSearchTerm
			self.rowContent = rowContent
			super.init()

			self.quickActionBar.contentSource = self
		}

		public func quickActionBar(
			_ quickActionBar: DSFQuickActionBar,
			identifiersForSearchTerm searchTerm: String
		) -> [AnyHashable] {
			return self.identifiersForSearchTerm(searchTerm)
		}

		public func quickActionBar(
			_ quickActionBar: DSFQuickActionBar,
			didSelectIdentifier identifier: AnyHashable
		) {
			// Update the selection
			self.selectedItem = identifier as? IdentifierType

			// Reflect the term that was searched for
			self.currentSearchText = quickActionBar.currentSearchText ?? ""

			// Tell the window to go away
			self.isVisible = false
		}

		public func quickActionBar(
			_ quickActionBar: DSFQuickActionBar,
			viewForIdentifier identifier: AnyHashable,
			searchTerm: String
		) -> NSView? {
			guard let item = identifier as? IdentifierType else {
				fatalError()
			}
			if let view = self.rowContent(item, searchTerm) {
				return NSHostingView<RowContent>(rootView: view)
			}
			return nil
		}

		public func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
			self.isVisible = false
		}
	}
}

#endif
