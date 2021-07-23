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
public extension DSFQuickActionBar {

	/// A SwiftUI implementation for DSFQuickActionBar
	class SwiftUI<RowContent: View>: NSObject, DSFQuickActionBarDelegate {
		private lazy var quickAction: DSFQuickActionBar = {
			let qb = DSFQuickActionBar()
			qb.delegate = self
			return qb
		}()

		private var identify: (String) -> [DSFQuickActionBar.ItemIdentifier] = { _ in [] }
		private var rowContent: (DSFQuickActionBar.ItemIdentifier) -> RowContent? = { _ in nil }
		private var action: (DSFQuickActionBar.ItemIdentifier) -> Void = { _ in }
		private var didCancel: (() -> Void)?

		public func present(
			placeholderText: String? = nil,
			searchIcon: DSFQuickActionBar.SearchIcon? = nil,
			identify: @escaping (String) -> [DSFQuickActionBar.ItemIdentifier],
			rowContent: @escaping (DSFQuickActionBar.ItemIdentifier) -> RowContent?,
			action: @escaping (DSFQuickActionBar.ItemIdentifier) -> Void,
			didCancel: (() -> Void)? = nil
		) {
			self.identify = identify
			self.rowContent = rowContent
			self.action = action
			self.didCancel = didCancel

			var searchFieldIcon: NSImage?
			if let icon = searchIcon {
				searchFieldIcon = icon.image.resizable().asNSImage(size: icon.size, isTemplate: icon.isTemplate)
			}

			self.quickAction.presentOnMainScreen(
				placeholderText: placeholderText,
				searchImage: searchFieldIcon
			)
		}

		public func quickActionBar(_: DSFQuickActionBar, identifiersForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {
			return self.identify(term)
		}

		public func quickActionBar(_: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
			if let view = self.rowContent(identifier) {
				return NSHostingView(rootView: view)
			}
			return nil
		}

		public func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
			self.action(identifier)
		}

		public func quickActionBarDidCancel(_: DSFQuickActionBar) {
			self.didCancel?()
		}
	}
}

#endif
