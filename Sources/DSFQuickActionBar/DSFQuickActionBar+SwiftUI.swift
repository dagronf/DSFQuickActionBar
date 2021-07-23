//
//  DSFQuickActionBar+SwiftUI.swift
//  DSFQuickActionBar
//
//  Created by Darren Ford on 23/7/21
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

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
public extension DSFQuickActionBar {
	// SwiftUI definitions for the image that appears next to the quick action bar's edit field
	struct SearchIcon {
		let image: Image
		let size: CGSize
		let isTemplate: Bool

		/// Create a SearchIcon
		/// - Parameters:
		///   - image: The image to display
		///   - size: The size of the image
		///   - isTemplate: If true, displays the image as a templated image
		public init(_ image: Image, size: CGSize = CGSize(width: 64, height: 64), isTemplate: Bool = false) {
			self.image = image
			self.size = size
			self.isTemplate = isTemplate
		}
	}
}

@available(macOS 10.15, *)
/// The QuickActionBar content source protocol
public protocol DSFQuickActionBarContentSource {
	/// Return an array of the identifiers to be displayed for the specified search term
	func identifiersForSearch(_ term: String) -> [DSFQuickActionBar.ItemIdentifier]
	/// Return the view to be displayed for the specified identifier
	func viewForIdentifier<RowContent: View>(_ identifier: DSFQuickActionBar.ItemIdentifier) -> RowContent?
	/// Called when the specified identifier is 'activated' (double clicked, return key pressed etc)
	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier)
	/// Called when the quick action bar was dismissed without selecting an item (optional)
	func didCancel()
}

@available(macOS 10.15, *)
public extension DSFQuickActionBarContentSource {
	/// Default implementation for cancel
	func didCancel() {}
}

@available(macOS 10.15, *)
public extension DSFQuickActionBar {
	/// A SwiftUI implementaion of DSFQuickActionBar
	class SwiftUI<RowContent: View> {
		public init() {}
		public func present(
			placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
			searchIcon: DSFQuickActionBar.SearchIcon? = nil,
			contentSource: DSFQuickActionBarContentSource) {
			self.contentSource = contentSource
			quickActionBar.present(
				placeholderText: placeholderText,
				searchIcon: searchIcon
			) { term in
				self.contentSource?.identifiersForSearch(term) ?? []
			}
			rowContent: { identifier in
				self.contentSource?.viewForIdentifier(identifier)
			}
			action: { identifier in
				self.contentSource?.didSelectIdentifier(identifier)
			}
			didCancel: {
				self.contentSource?.didCancel()
			}
		}

		// MARK: - Private
		private let quickActionBar = DSFQuickActionBar.CoreSwiftUI<RowContent>()
		private var contentSource: DSFQuickActionBarContentSource?
	}
}
#endif
