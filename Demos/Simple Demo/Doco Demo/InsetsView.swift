//
//  InsetsView.swift
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
import Foundation

class InsetsView: NSView {
	convenience init(_ child: NSView, inset: Double, priority: NSLayoutConstraint.Priority = .init(999)) {
		self.init(
			child,
			insets: NSEdgeInsets(top: inset, left: inset, bottom: inset, right: inset),
			priority: priority
		)
	}

	init(_ child: NSView, insets: NSEdgeInsets, priority: NSLayoutConstraint.Priority = .init(999)) {
		super.init(frame: .zero)
		self.setup(child: child, insets: insets, priority: priority)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension InsetsView {
	private func setup(child: NSView, insets: NSEdgeInsets, priority: NSLayoutConstraint.Priority) {
		self.translatesAutoresizingMaskIntoConstraints = false
		child.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(child)

		var c = NSLayoutConstraint(item: child, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: insets.left)
		c.priority = priority
		self.addConstraint(c)

		c = NSLayoutConstraint(item: child, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -insets.right)
		c.priority = priority
		self.addConstraint(c)

		c = NSLayoutConstraint(item: child, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top)
		c.priority = priority
		self.addConstraint(c)

		c = NSLayoutConstraint(item: child, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -insets.bottom)
		c.priority = priority
		self.addConstraint(c)
	}

}

//		self.addConstraints(
//			NSLayoutConstraint.constraints(
//				withVisualFormat: "H:|-(leading@999)-[child]-(trailing@999)-|",
//				metrics: [
//					"leading": NSNumber(value: insets.left),
//					"trailing": NSNumber(value: insets.right),
//				]
//				, views: [
//					"child": child
//				]
//			)
//		)
//
//		self.addConstraints(
//			NSLayoutConstraint.constraints(
//				withVisualFormat: "V:|-(top@999)-[child]-(bottom@999)-|",
//				metrics: [
//					"top": NSNumber(value: insets.top),
//					"bottom": NSNumber(value: insets.bottom),
//				]
//				, views: [
//					"child": child
//				]
//			)
//		)
