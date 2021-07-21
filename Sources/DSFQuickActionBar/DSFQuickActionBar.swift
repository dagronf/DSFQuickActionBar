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

public class DSFQuickActionBar {

	public static let DefaultWidth: CGFloat = 500.0

	public weak var delegate: DSFQuickActionBarDelegate?

	internal weak var quickActionBarWindow: DSFQuickActionBar.Window?
	internal var quickBarController: DSFQuickActionBar.WindowController?

	var width: CGFloat = 0
	var placeholderText: String = "Quick Actions"

	public init() {

	}

	/// The current list of completions
	var completions: [DSFQuickActionBar.CompletionIdentity] = []

	/// Current search results
	var matches: [DSFQuickActionBar.CompletionIdentity] = []

	/// Update with new search text
	func updateSearch(_ searchText: String) {
		matches = [DSFQuickActionBar.CompletionIdentity](completions
			.filter { $0.matchString.localizedCaseInsensitiveContains(searchText) }
			.sorted(by: { a, b in a.matchString < b.matchString } )
			.prefix(100))
		quickActionBarWindow?.reloadData()

		if matches.count == 0 {
			self.quickActionBarWindow?.results.isHidden = true
		}
		else {
			self.quickActionBarWindow?.results.isHidden = false
		}
	}
}

public extension DSFQuickActionBar {

	func present(in parent: NSWindow,
					 placeholderText: String? = nil,
					 width: CGFloat = DSFQuickActionBar.DefaultWidth) {

		let originRect = parent.frame

		self.width = width
		if let text = placeholderText {
			self.placeholderText = text
		}


		let w2: CGFloat = width //whatever you want the width to be
		let h2: CGFloat = 100   //whatever you want the height to be

		let x2 = originRect.origin.x + ((originRect.width - w2) / 2.0)
		let y2 = originRect.origin.y + ((originRect.height - h2) / 1.3)
		let posRect = CGRect(x: x2, y: y2, width: w2, height: h2)


		let quickBarWindow = DSFQuickActionBar.Window()
		self.quickActionBarWindow = quickBarWindow

		quickBarWindow.quickActionBar = self
		quickBarWindow.setFrame(posRect, display: true)
		quickBarWindow.setup(parentWindow: parent)
		quickBarWindow.makeKey()

		quickBarController = WindowController(window: quickBarWindow)
		quickBarController?.setupWindowListener { [weak self] in
			self?.quickBarController = nil
		}

		self.completions = self.delegate?.quickBarCompletions(for: self) ?? []

	}

}

extension DSFQuickActionBar {

	func reloadData() {
		guard let d = delegate else { return }

		// Ask the delegate for the current list of completions
		self.completions = d.quickBarCompletions(for: self)

		// ... and ask the window to update itself
		self.quickActionBarWindow?.reloadData()

	}

}
