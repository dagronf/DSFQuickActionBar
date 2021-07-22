//
//  DSFQuickActionBar+Delegate.swift
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

/// Delegate for a QSFQuickActionBar instance
public protocol DSFQuickActionBarDelegate: NSObjectProtocol {
	/// Return an array of the identifiers to be displayed for the specified search term
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier]

	/// Return the view to be displayed for the specified identifier
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView?

	/// Called when the specified identifier is 'activated' (double clicked, return key pressed etc)
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier)

	/// Called when the quick action bar was dismissed without selecting an item (optional)
	func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar)
}

extension DSFQuickActionBarDelegate {
	/// Default implementation for cancel
	public func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		// Do nothing
	}
}
