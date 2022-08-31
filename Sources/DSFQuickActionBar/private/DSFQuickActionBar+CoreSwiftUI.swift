//
//  DSFQuickActionBar+CoreSwiftUI.swift
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

//#if canImport(SwiftUI)
//
//import SwiftUI
//
//@available(macOS 10.15, *)
//extension DSFQuickActionBar {
//
//	/// A SwiftUI wrapper for DSFQuickActionBar
//	internal class CoreSwiftUI<RowContent: View>: NSObject, DSFQuickActionBarContentSource {
//		private lazy var quickAction: DSFQuickActionBar = {
//			let qb = DSFQuickActionBar()
//			qb.contentSource = self
//			return qb
//		}()
//
//		private var identify: (String) -> [DSFQuickActionBar.ItemIdentifier] = { _ in [] }
//		private var rowContent: (DSFQuickActionBar.ItemIdentifier, String) -> RowContent? = { _, _ in nil }
//		private var action: (DSFQuickActionBar.ItemIdentifier) -> Void = { _ in }
//		private var didCancel: (() -> Void)?
//
//		/// Present the Quick Action Bar on the screen
//		/// - Parameters:
//		///   - screenPosition: The position on the screen for the bar, or nil for center of current screen
//		///   - placeholderText: The placeholder text to display in the bar
//		///   - searchIcon: The icon to use on the left of the bar, or nil to not have a bar icon
//		///   - initialSearchText: The initial search text to display in the bar
//		///   - width: The width of the bar on-screen
//		///   - identify: The block to call to retrieve the identifiers for the specified search term
//		///   - rowContent: The block called to retrieve a View representing the identifier in the result list
//		///   - action: The action to perform when the user selects an item in the result list
//		///   - didCancel: Called when the user cancels the quick action bar (eg. hit escape, or make it lose focus)
//		func present(
//			screenPosition: CGRect? = nil,
//			placeholderText: String? = nil,
//			searchIcon: DSFQuickActionBar.SearchIcon? = nil,
//			initialSearchText: String? = nil,
//			width: CGFloat = DSFQuickActionBar.FloatingDefaultWidth,
//			identify: @escaping (String) -> [DSFQuickActionBar.ItemIdentifier],
//			rowContent: @escaping (DSFQuickActionBar.ItemIdentifier, String) -> RowContent?,
//			action: @escaping (DSFQuickActionBar.ItemIdentifier) -> Void,
//			didCancel: (() -> Void)? = nil
//		) {
//			self.identify = identify
//			self.rowContent = rowContent
//			self.action = action
//			self.didCancel = didCancel
//
//			var searchFieldIcon: NSImage?
//			if let icon = searchIcon {
//				if icon.image == nil {
//					// Default image
//					searchFieldIcon = DSFQuickActionBar.DefaultImage
//				}
//				else if let image = icon.image {
//					// Specified image
//					searchFieldIcon = image.resizable().asNSImage(size: icon.size, isTemplate: icon.isTemplate)
//				}
//			}
//
//			self.quickAction.present(
//				screenPosition: pos,
//				placeholderText: placeholderText,
//				searchImage: searchFieldIcon,
//				initialSearchText: initialSearchText,
//				width: width
//			)
//
//			if let pos = screenPosition {
//				self.quickAction.present(
//					screenPosition: pos,
//					placeholderText: placeholderText,
//					searchImage: searchFieldIcon,
//					initialSearchText: initialSearchText,
//					width: width
//				)
//			}
//			else {
//				self.quickAction.presentOnMainScreen(
//					placeholderText: placeholderText,
//					searchImage: searchFieldIcon,
//					initialSearchText: initialSearchText,
//					width: width
//				)
//			}
//		}
//
//		func quickActionBar(_ quickActionBar: DSFQuickActionBar, identifiersForSearchTerm searchTerm: String) -> [DSFQuickActionBar.ItemIdentifier] {
//			return self.identify(searchTerm)
//		}
//
//		func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier, searchTerm: String) -> NSView? {
//			if let view = self.rowContent(identifier, searchTerm) {
//				return NSHostingView(rootView: view)
//			}
//			return nil
//		}
//
//		func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
//			self.action(identifier)
//		}
//
//		func quickActionBarDidCancel(_: DSFQuickActionBar) {
//			self.didCancel?()
//		}
//	}
//}
//
//#endif
