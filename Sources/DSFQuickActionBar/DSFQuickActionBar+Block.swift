//
//  DSFQuickActionBar+Block.swift
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

extension DSFQuickActionBar {
	/// A quick action bar using block callbacks instead of delegate callbacks
	///
	/// Useful if you don't want to pollute your existing codebase with delegate handling, plus better handling
	/// of identifier types via template parameters
	public class Block<IdentifierType: Hashable, RowContentView: NSView>: NSObject {

		public typealias ViewForIdentifierType = (_ identifier: IdentifierType, _ searchTerm: String) -> RowContentView?

		/// **[required]** Return an array of identifiers that match against the search term
		///
		/// This block is called passing a task object containing :-
		///  * the search term
		///  * a completion block which must be called when the search task is complete
		public var identifiersForSearchTerm: (_ task: DSFQuickActionBar.SearchTask) -> Void = { task in
			Swift.print("[DSFQuickActionBar.Source]: Must implement identifiersForSearchTermAsync")
			task.complete(with: [])
		}

		/// **[required]** Returns a view for the specified identifier. Passes the current search term
		public var viewForIdentifier: ViewForIdentifierType? = { identifier, searchTerm in
			assert(false, "[DSFQuickActionBar.Source]: Must implement viewForIdentifier")
			return nil
		}

		/// **[required]** Called when the user 'activates' an identifier
		public var didActivateIdentifier: ((IdentifierType) -> Void)? = { identifier in
			assert(false, "[DSFQuickActionBar.Source]: Must implement didActivateIdentifier")
		}

		/// Called when an identifier is about to be selected in the quick action bar
		///
		/// Return `false` to stop the identifier from being selected
		public var canSelectIdentifier: ((IdentifierType) -> Bool)?

		/// Called when an identifier is selected within the quick action bar
		public var didSelectIdentifier: ((IdentifierType) -> Void)?

		/// Called when the user cancels the quick action bar.
		///
		/// This can be triggered a number of ways, such as :-
		/// * user hitting the `esc` key to dismiss
		/// * the quick action bar loses key focus
		///
		/// This will **NOT** be called if the user activates an item in the list
		public var didCancel: (() -> Void)?

		/// Called when the quick action bar closes.
		///
		/// This is called :-
		/// * If the user cancels the quick action bar
		/// * The user activates an item in the quick action bar
		public var didClose: (() -> Void)?

		/// The placeholder text to display in the quick action bar when the search text is empty
		public var placeholderText: String? = nil

		/// The size of the quick action bar window
		public var size: CGSize = CGSize(
			width: (NSScreen.main?.frame.width ?? (DSFQuickActionBar.DefaultWidth*4)) / 4.0,
			height: (NSScreen.main?.frame.height ?? (DSFQuickActionBar.DefaultHeight*4)) / 4.0
		)

		/// Does the quick action bar show keyboard shortcuts for the first 10 items?
		public var showsKeyboardShortcuts = false

		/// The image to display on the left of the search term
		public var searchImage: NSImage? = nil

		/// The number of clicks required to activate a row in the results view
		public var requiredClickCount: RequiredClickCount {
			get { self.qab.requiredClickCount }
			set { self.qab.requiredClickCount = newValue }
		}

		/// A convenience for retrieving the most recent search term
		public private(set) var lastSearchTerm: String = ""

		/// Create a quick action bar source
		public override init() {
			super.init()
			qab.contentSource = self
		}

		/// Show the quick action bar
		/// - Parameters:
		///   - initialSearchTerm: The search term to search when the quick action bar is initially presented
		///   - parentWindow: The window to attach the quick action bar to. If nil, presents for the current screen
		public func show(
			initialSearchTerm: String? = nil,
			parentWindow: NSWindow? = nil
		) {
			qab.present(
				parentWindow: parentWindow,
				placeholderText: placeholderText,
				searchImage: searchImage,
				initialSearchText: initialSearchTerm,
				width: size.width,
				height: size.height,
				showKeyboardShortcuts: showsKeyboardShortcuts,
				didClose: didClose
			)
		}

		/// Cancel the quick action bar if it is displayed
		public func cancel() {
			self.qab.cancel()
		}

		// private

		private let qab = DSFQuickActionBar()
	}
}

// MARK: - Delegate callback handling

extension DSFQuickActionBar.Block: DSFQuickActionBarContentSource {

	public func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTermTask task: DSFQuickActionBar.SearchTask) {
		self.lastSearchTerm = task.searchTerm
		self.identifiersForSearchTerm(task)
	}

	public func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView? {
		guard let item = item as? IdentifierType else { fatalError() }
		return viewForIdentifier?(item, searchTerm)
	}

	public func quickActionBar(_ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable) -> Bool {
		guard let item = item as? IdentifierType else { fatalError() }
		return canSelectIdentifier?(item) ?? true
	}

	public func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: AnyHashable) {
		guard let item = item as? IdentifierType else { fatalError() }
		didSelectIdentifier?(item)
	}

	public func quickActionBar(_ quickActionBar: DSFQuickActionBar, didActivateItem item: AnyHashable) {
		guard let item = item as? IdentifierType else { fatalError() }
		didActivateIdentifier?(item)
	}

	public func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		didCancel?()
	}
}
