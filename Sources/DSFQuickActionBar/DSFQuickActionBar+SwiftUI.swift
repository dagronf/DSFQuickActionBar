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

		/// The default image for the search icon
		public static let Default = SearchIcon()

		internal let image: Image?
		internal let size: CGSize
		internal let isTemplate: Bool

		/// Create a SearchIcon
		/// - Parameters:
		///   - image: The image to display
		///   - size: The size of the image
		///   - isTemplate: If true, displays the image as a templated image
		public init(
			_ image: Image? = nil,
			size: CGSize = CGSize(width: 64, height: 64),
			isTemplate: Bool = false
		) {
			self.image = image
			self.size = size
			self.isTemplate = isTemplate
		}
	}
}

@available(macOS 10.15, *)
/// The QuickActionBar SwiftUI content source protocol
public protocol DSFQuickActionBarSwiftUIContentSource {
	/// Return an array of the identifiers to be displayed for the specified search term
	func identifiersForSearch(_ searchTerm: String) -> [DSFQuickActionBar.ItemIdentifier]
	/// Return the view to be displayed for the specified identifier and search term
	func viewForIdentifier<RowContent: View>(_ identifier: DSFQuickActionBar.ItemIdentifier, searchTerm: String) -> RowContent?
	/// Called when the specified identifier is 'activated' (double clicked, return key pressed etc)
	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier)
	/// Called when the quick action bar was dismissed without selecting an item (optional)
	func didCancel()
}

@available(macOS 10.15, *)
public extension DSFQuickActionBarSwiftUIContentSource {
	/// Default implementation for cancel
	func didCancel() {}
}

@available(macOS 10.15, *)
public extension DSFQuickActionBar {
	/// A SwiftUI implementaion of DSFQuickActionBar
	class SwiftUI<RowContent: View> {
		public init() {}

		/// Presents a DSFQuickActionBar on the main screen
		/// - Parameters:
		///   - screenPosition: the position on the current screen to present the bar, or nil for centering on screen
		///   - placeholderText: (optional) the placeholder text to display in the search field
		///   - searchIcon: (optional) the image to use as the search image. If nil, no search field image is displayed. If not specified, uses the default image
		///   - initialSearchText: (optional) the text to initially populate the search field with
		///   - width: the width of the quick action bar to display
		///   - contentSource: The data source for the quick action bar content
		public func present(
			screenPosition: CGRect? = nil,
			placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
			searchIcon: DSFQuickActionBar.SearchIcon? = DSFQuickActionBar.SearchIcon.Default,
			initialSearchText: String? = nil,
			width _: CGFloat = DSFQuickActionBar.DefaultWidth,
			contentSource: DSFQuickActionBarSwiftUIContentSource
		) {
			self.contentSource = contentSource
			self.quickActionBar.present(
				screenPosition: screenPosition,
				placeholderText: placeholderText,
				searchIcon: searchIcon,
				initialSearchText: initialSearchText
			) { term in
				self.contentSource?.identifiersForSearch(term) ?? []
			}
			rowContent: { identifier, searchTerm in
				self.contentSource?.viewForIdentifier(identifier, searchTerm: searchTerm)
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
		private var contentSource: DSFQuickActionBarSwiftUIContentSource?
	}
}
#endif
