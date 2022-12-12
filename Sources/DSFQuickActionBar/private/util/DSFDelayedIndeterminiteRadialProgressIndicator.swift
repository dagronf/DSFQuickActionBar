//
//  DSFDelayedIndeterminiteRadialProgressIndicator.swift
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

import Foundation
import AppKit

/// A radial, indeterminite, NSProgressIndicator instance that delays its visibility for a specific time
@IBDesignable
class DSFDelayedIndeterminiteRadialProgressIndicator: NSProgressIndicator {
	/// The time to delay before displaying the spinner.
	@IBInspectable var delayUntilDisplay: TimeInterval = 0.25

	convenience init() {
		self.init(frame: .zero)
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	/// Start the animation. The spinner will only become visible after the delay time
	///
	/// Must be called on the main thread
	override func startAnimation(_ sender: Any?) {
		assert(Thread.isMainThread)
		// If we're already waiting, just ignore the request
		guard self._timer == nil || self.isHidden == false else {
			return
		}
		self._timer = DSFSingleShotTimer(delay: self.delayUntilDisplay) { [weak self] in
			self?.delayedStart()
		}
	}

	/// Stop and hide the spinner if it is visible
	///
	/// Must be called on the main thread
	override func stopAnimation(_ sender: Any?) {
		assert(Thread.isMainThread)
		self._timer?.cancel()
		self._timer = nil
		super.stopAnimation(self)
	}

	// private
	private var _timer: DSFSingleShotTimer?
}

private extension DSFDelayedIndeterminiteRadialProgressIndicator {
	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true
		self.usesThreadedAnimation = true
		self.isIndeterminate = true
		self.isDisplayedWhenStopped = false
		self.style = .spinning
		self.controlSize = .regular

		self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		self.setContentHuggingPriority(.defaultHigh, for: .vertical)
		self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
	}

	func delayedStart() {
		//self._timer?.cancel()
		self._timer = nil
		super.startAnimation(self)
	}
}
