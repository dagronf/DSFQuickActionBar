//
//  DSFQuickActionBar+Window.swift
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

extension DSFQuickActionBar {

	class Window: NSWindow {

		var quickActionBar: DSFQuickActionBar!

		let debouncer = DSFDebounce(seconds: 0.2)

		// Allow the window to become key
		override var canBecomeKey: Bool { return true }
		override var canBecomeMain: Bool { return true }

		// Primary container
		private lazy var primaryStack: NSStackView = {
			let stack = NSStackView()
			stack.identifier = NSUserInterfaceItemIdentifier("primary")
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.orientation = .vertical
			stack.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

			stack.setContentHuggingPriority(.required, for: .horizontal)
			stack.setContentHuggingPriority(.required, for: .vertical)
			stack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

			stack.setHuggingPriority(.required, for: .vertical)

			stack.needsLayout = true

			return stack
		}()

		// The edit label
		private lazy var editLabel: NSTextField = {
			let t = NSTextField()
			t.translatesAutoresizingMaskIntoConstraints = false
			t.wantsLayer = true
			t.drawsBackground = false
			t.isBordered = false
			t.isBezeled = false
			t.font = NSFont.systemFont(ofSize: 28, weight: .light)
			t.textColor = NSColor.textColor
			t.alignment = .left
			t.isEnabled = true
			t.isEditable = true
			t.isSelectable = true

			t.focusRingType = .none

			t.setContentHuggingPriority(.defaultLow, for: .horizontal)
			t.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

			return t
		}()

		// The upper left image
		private lazy var searchImage: NSImageView = {
			let imageView = NSImageView()
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
			imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 28))
			imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 32))
			imageView.imageScaling = .scaleProportionallyUpOrDown

			let image = NSImage(named: "NSQuickLookTemplate")!
			image.isTemplate = true
			imageView.image = image
			return imageView
		}()

		// The stack of '[image] | [edit field]'
		private lazy var searchStack: NSStackView = {
			let stack = NSStackView()
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.orientation = .horizontal

			stack.addArrangedSubview(searchImage)

			stack.addArrangedSubview(editLabel)
			editLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
			editLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

			stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
			stack.setContentHuggingPriority(.defaultHigh, for: .vertical)

			stack.setHuggingPriority(.required, for: .vertical)

			return stack
		}()

		// The results view
		lazy var results: DSFQuickActionBar.ResultsView = {
			let r = DSFQuickActionBar.ResultsView()
			r.translatesAutoresizingMaskIntoConstraints = false
			r.setContentHuggingPriority(.defaultLow, for: .horizontal)
			r.quickActionBar = self.quickActionBar
			r.configure()

			return r
		}()
	}
}

extension DSFQuickActionBar.Window {
	func reloadData() {
		self.results.tableView.reloadData()
	}
}

internal extension DSFQuickActionBar.Window {

	func setup(parentWindow: NSWindow? = nil) {

		self.autorecalculatesKeyViewLoop = true

		primaryStack.translatesAutoresizingMaskIntoConstraints = false
		primaryStack.setContentHuggingPriority(.required, for: .horizontal)
		primaryStack.setContentHuggingPriority(.required, for: .vertical)

		self.contentView = primaryStack //   baseView

		self.backgroundColor = NSColor.clear
		self.isOpaque = false
		self.styleMask = [.borderless]
		self.isMovableByWindowBackground = true
		self.makeKeyAndOrderFront(self)

		primaryStack.wantsLayer = true
		let baseLayer = primaryStack.layer!

		baseLayer.cornerRadius = 10
		baseLayer.backgroundColor = NSColor.controlBackgroundColor.cgColor
		baseLayer.borderColor = NSColor.controlColor.cgColor
		baseLayer.borderWidth = self.backingScaleFactor == 2 ? 0.5 : 1.0

		primaryStack.needsLayout = true

		primaryStack.addArrangedSubview(searchStack)

		results.isHidden = true
		primaryStack.addArrangedSubview(results)

		editLabel.placeholderString = self.quickActionBar.placeholderText
		editLabel.delegate = self

		self.makeFirstResponder(editLabel)


		self.invalidateShadow()

		self.level = .floating

		if let parent = parentWindow {
			self.order(.above, relativeTo: parent.windowNumber)
		}

		self.primaryStack.layoutSubtreeIfNeeded()

		textChanged()
	}
}

extension DSFQuickActionBar.Window {
	override func cancelOperation(_ sender: Any?) {
		self.quickActionBar.delegate?.quickActionBarDidCancel(self.quickActionBar)
		self.resignKey()
	}

	func pressedLeftArrowInResultsView() {
		self.makeFirstResponder(self.editLabel)
	}

}

extension DSFQuickActionBar.Window: NSTextFieldDelegate {

	func controlTextDidChange(_ obj: Notification) {
		self.debouncer.debounce { [weak self] in
			self?.textChanged()
		}
	}

	func textChanged() {
		guard let delegate = self.quickActionBar.delegate else { return }

		let currentSearch = self.editLabel.stringValue

		// Get a list of the identifiers than match
		let identifiers = delegate.quickActionBar(self.quickActionBar, itemsForSearchTerm: currentSearch)

		// And update the display list
		self.results.identifiers = identifiers
	}

	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		if commandSelector == #selector(moveDown(_:)) {
			self.makeFirstResponder(self.results.tableView)
			let selection: Int = (self.results.tableView.selectedRow == -1) ? 0 : self.results.tableView.selectedRow
			self.results.tableView.selectRowIndexes(IndexSet(integer: selection), byExtendingSelection: false)
			return true
		}
		return false
	}
}


// MARK: - WindowController

extension DSFQuickActionBar {
	class WindowController: NSWindowController {
		func setupWindowListener(_ completion: @escaping () -> Void) {
			NotificationCenter.default.addObserver(
				forName: NSWindow.didResignKeyNotification,
				object: self.window,
				queue: .main) { [weak self] _ in
				  self?.close()
			}

			NotificationCenter.default.addObserver(
				forName: NSWindow.willCloseNotification,
				object: self.window,
				queue: .main) { _ in
				completion()
			}
		}
	}
}
