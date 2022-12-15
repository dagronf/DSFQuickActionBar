//
//  DSFPrimaryRoundedView.swift
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

import DSFAppearanceManager

/// The primary drawing view for the quick action bar.
final class DSFPrimaryRoundedView: NSView {

	override var allowsVibrancy: Bool { true }
	override var wantsUpdateLayer: Bool { true }

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.wantsLayer = true
		self.translatesAutoresizingMaskIntoConstraints = false

		if #available(macOS 10.14, *), !DSFAppearanceCache.shared.reduceTransparency {
			let blurView = NSVisualEffectView()
			blurView.translatesAutoresizingMaskIntoConstraints = false
			blurView.wantsLayer = true
			blurView.blendingMode = .behindWindow
			blurView.material = .menu
			blurView.state = .active
			blurView.setContentHuggingPriority(.defaultLow, for: .vertical)
			blurView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			blurView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
			blurView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
			self.addSubview(blurView)
			self.addConstraint(NSLayoutConstraint(item: blurView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: blurView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: -5))
			self.addConstraint(NSLayoutConstraint(item: blurView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

			blurView.layer!.mask = self.layer!
		}
	}

	override func updateLayer() {
		let baseLayer = self.layer!
		baseLayer.cornerRadius = 10
		baseLayer.backgroundColor = NSColor.windowBackgroundColor.cgColor

		// Attempting to match the style of spotlight
		if DSFAppearanceCache.shared.isDark {
			baseLayer.borderWidth = 1
			baseLayer.borderColor =
				DSFAppearanceCache.shared.increaseContrast
					? NSColor.secondaryLabelColor.cgColor
					: NSColor.tertiaryLabelColor.cgColor
		}
		else {
			baseLayer.borderWidth = 0
		}
	}
}
