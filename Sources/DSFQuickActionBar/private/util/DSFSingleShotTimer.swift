//
//  DSFSingleShotTimer.swift
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

// A single use cancellable timer
class DSFSingleShotTimer {
	/// Create a single-use timer object
	/// - Parameters:
	///   - delay: The amount of time to delay before calling
	///   - queue: The queue to on which to call the completion block
	///   - completionBlock: Called when the timer
	init(delay: TimeInterval, queue: DispatchQueue = .main, _ completionBlock: @escaping () -> Void) {
		Swift.print("SingleShotTimer: init")
		self.workItem = DispatchWorkItem(block: {
			completionBlock()
		})
		queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
	}

	func cancel() {
		Swift.print("SingleShotTimer: cancel")
		self.stop()
	}

	deinit {
		Swift.print("SingleShotTimer: deinit")
		self.stop()
	}

	// Private
	private var workItem: DispatchWorkItem?
}

private extension DSFSingleShotTimer {
	private func stop() {
		self.workItem?.cancel()
		self.workItem = nil
	}
}
