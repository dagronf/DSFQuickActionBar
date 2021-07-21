//
//  DSFQuickActionBarDelegate.swift
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

public protocol DSFQuickActionBarDelegate: NSObjectProtocol {
	func quickBarCompletions(for quickActionBar: DSFQuickActionBar) -> [DSFQuickActionBar.CompletionIdentity]
	func quickBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier: DSFQuickActionBar.CompletionIdentity) -> NSView?
	func quickBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: DSFQuickActionBar.CompletionIdentity)
	func quickBarDidCancel(_ quickActionBar: DSFQuickActionBar)
}

extension DSFQuickActionBarDelegate {
	public func quickBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		// Do nothing
	}
}

extension DSFQuickActionBar {
	public struct CompletionIdentity: Identifiable {
		public let id = UUID()
		public let matchString: String
		public init(matchString: String) {
			self.matchString = matchString
		}
	}
}
