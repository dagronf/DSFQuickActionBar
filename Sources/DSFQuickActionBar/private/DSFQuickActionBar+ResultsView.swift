//
//  DSFQuickActionBar+ResultsView.swift
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
import DSFAppearanceManager

extension DSFQuickActionBar {
	class ResultsView: NSView {
		private let scrollView = NSScrollView()
		private let tableView = DSFQuickActionBar.ResultsTableView()
		private let horizontalView = NSBox()

		// The parent
		var quickActionBar: DSFQuickActionBar!

		// Do we show keyboard shortcuts?
		var showKeyboardShortcuts = false

		var currentSearchTerm = ""
		var identifiers: [AnyHashable] = [] {
			didSet {
				self.shortcutKeyboardMap = [:]
				self.nextShortcutIndex = 0
				self.isHidden = self.identifiers.count == 0
				self.tableView.reloadData()
				if self.identifiers.count > 0 {
					_ = self.selectFirstSelectableRow()
				}
			}
		}

		// Returns the currently selected row in the list
		@inlinable var selectedRow: Int {
			return self.tableView.selectedRow
		}

		override init(frame frameRect: NSRect) {
			super.init(frame: frameRect)
			self.translatesAutoresizingMaskIntoConstraints = false
			self.setContentHuggingPriority(.defaultLow, for: .horizontal)
		}

		@available(*, unavailable)
		required init?(coder _: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		// Private

		// The font for displaying the keyboard shortcut
		private let keyboardShortcutFont = NSFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
		// keyboard shortcut assigning
		private var shortcutKeyboardMap: [Int: AnyHashable] = [:]
		private var nextShortcutIndex = 0
	}
}

extension DSFQuickActionBar.ResultsView {
	func configure() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		tableView.translatesAutoresizingMaskIntoConstraints = false

		scrollView.contentView = DSFFlippedClipView()

		horizontalView.boxType = .separator
		horizontalView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(horizontalView)
		self.addConstraint(NSLayoutConstraint(item: horizontalView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: horizontalView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: horizontalView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))

		self.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))

		scrollView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.quickActionBar.width))
		scrollView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.quickActionBar.height))

		// Scrollview
		scrollView.backgroundColor = NSColor.clear
		scrollView.drawsBackground = false
		scrollView.autohidesScrollers = true
		scrollView.documentView = tableView
		scrollView.hasHorizontalScroller = false
		scrollView.hasVerticalScroller = true

		// Embedded table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.parent = self
		tableView.headerView = nil
		tableView.backgroundColor = NSColor.clear
		tableView.intercellSpacing = NSSize(width: 0, height: 5)

		if #available(macOS 10.13, *) {
			tableView.usesAutomaticRowHeights = true
		}
		else {
			// For macOS 10.11 and 10.12, it doesn't support usesAutomaticRowHeights.
			// User has to specify rowHeight in the parent class
			tableView.rowHeight = self.quickActionBar.rowHeight
		}

		// Table column
		let c = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("searchresult"))
		tableView.addTableColumn(c)

		// Callback when a row is clicked by the user
		tableView.action = #selector(didClickRow)
		tableView.doubleAction = #selector(didDoubleClickRow)
	}
}

// MARK: - Table Data

extension DSFQuickActionBar.ResultsView: NSTableViewDelegate, NSTableViewDataSource {
	@inlinable func reloadData() {
		self.tableView.reloadData()
	}

	@inlinable var contentSource: DSFQuickActionBarContentSource? {
		self.quickActionBar.contentSource
	}

	func numberOfRows(in _: NSTableView) -> Int {
		self.identifiers.count
	}

	func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
		let itemIdentifier = self.identifiers[row]

		let content = self.contentSource?.quickActionBar(
			self.quickActionBar,
			viewForItem: itemIdentifier,
			searchTerm: currentSearchTerm
		) ?? NSView()

		guard
			self.showKeyboardShortcuts,
			(0 ... 9).contains(self.nextShortcutIndex),
			row < self.identifiers.count
		else {
			return content
		}

		guard self.contentSource?.quickActionBar(self.quickActionBar, canSelectItem: itemIdentifier) ?? false else {
			return content
		}

		content.translatesAutoresizingMaskIntoConstraints = false
		content.setContentHuggingPriority(.defaultLow, for: .horizontal)

		let container = NSView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(content)

		container.addConstraint(NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0))

		let row = self.nextShortcutIndex
		self.shortcutKeyboardMap[row] = itemIdentifier

		let t = row == 0 ? NSTextField(labelWithString: "↩︎") : NSTextField(labelWithString: "⌘\(row)")
		t.alignment = .right
		t.translatesAutoresizingMaskIntoConstraints = false
		t.font = self.keyboardShortcutFont
		t.textColor = .secondaryLabelColor
		t.setContentHuggingPriority(.init(999), for: .horizontal)
		t.setContentHuggingPriority(.required, for: .vertical)
		container.addSubview(t)

		// A hack for layout on pre-11 systems. Autolayout didn't account for the appearance of scrollbars back then
		var inset: CGFloat = -24
		if #available(macOS 11, *) {
			inset = 0
		}

		container.addConstraint(NSLayoutConstraint(item: t, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: inset))
		container.addConstraint(NSLayoutConstraint(item: t, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: t, attribute: .leading, relatedBy: .equal, toItem: content, attribute: .trailing, multiplier: 1, constant: 4))

		nextShortcutIndex += 1

		return container
	}

	class ContainerView: NSView {
		let keyboard: NSTextField = {
			let t = NSTextField(labelWithString: "")
			t.alignment = .center
			t.translatesAutoresizingMaskIntoConstraints = false
			t.font = .systemFont(ofSize: 16, weight: .medium)
			t.textColor = .secondaryLabelColor
			t.setContentHuggingPriority(.required, for: .horizontal)
			t.setContentHuggingPriority(.defaultLow, for: .vertical)
			return t
		}()

		private var content = NSView()
		@available(*, unavailable)
		required init?(coder: NSCoder) { fatalError() }
		init() {
			super.init(frame: .zero)
			self.translatesAutoresizingMaskIntoConstraints = false

			self.configure()
		}

		func set(_ content: NSView, shortcutKey: Character) {
			self.content = content
			self.keyboard.stringValue = "\(shortcutKey)"
			self.configure()
		}

		func configure() {
			self.keyboard.removeFromSuperview()
			self.content.removeFromSuperview()

			self.addSubview(self.content)
			self.content.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(self.keyboard)

			self.addConstraint(NSLayoutConstraint(item: self.content, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: self.content, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: self.content, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

			self.addConstraint(NSLayoutConstraint(item: self.keyboard, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: self.keyboard, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: self.keyboard, attribute: .leading, relatedBy: .equal, toItem: self.content, attribute: .trailing, multiplier: 1, constant: 4))
			self.addConstraint(NSLayoutConstraint(item: self.keyboard, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
		}
	}

	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		if row < 0 { return false }
		return self.contentSource?.quickActionBar(
			self.quickActionBar,
			canSelectItem: self.identifiers[row]
		) ?? false
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		assert(self.selectedRow < self.identifiers.count)
		self.contentSource?.quickActionBar(
			self.quickActionBar,
			didSelectItem: self.identifiers[self.selectedRow]
		)
	}

	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		ResultsRowView()
	}
}

// MARK: - Table Actions

extension DSFQuickActionBar.ResultsView {
	@objc private func didClickRow() {
		if quickActionBar.requiredClickCount == .single {
			self.rowAction()
		}
	}

	@objc private func didDoubleClickRow() {
		self.rowAction()
	}

	func performShortcutAction(for itemIndex: Int) -> Bool {
		guard itemIndex >= 0, itemIndex <= 9, let itemIdentifier = self.shortcutKeyboardMap[itemIndex] else {
			return false
		}

		self.quickActionBar.contentSource?.quickActionBar(self.quickActionBar, didActivateItem: itemIdentifier)

		// Close the bar
		self.window?.resignMain()

		return true
	}

	func rowAction() {
		let selectedRow = self.tableView.selectedRow
		if selectedRow < 0 || selectedRow >= self.identifiers.count {
			return
		}

		// If the user clicked a row, check to see if the row can be selected BEFORE
		// performing the action on the row.
		if
			self.tableView.clickedRow >= 0,
			self.tableView(self.tableView, shouldSelectRow: self.tableView.clickedRow) == false
		{
			return
		}

		let itemIdentifier = self.identifiers[selectedRow]
		self.quickActionBar.contentSource?.quickActionBar(self.quickActionBar, didActivateItem: itemIdentifier)

		// If the row is double-clicked, close the bar
		self.window?.resignMain()
	}

	func backAction() {
		self.quickActionBar.quickActionBarWindow?.pressedLeftArrowInResultsView()
	}
}

// MARK: - Safe external selection

extension DSFQuickActionBar.ResultsView {
	/// Selects the first selectable row in the table
	///
	/// * Skips any row(s) that identify themselves as 'unselectable'
	/// * If there are no selectable rows in the results table, no selection is made
	func selectFirstSelectableRow() -> Bool {
		for index in 0 ..< self.identifiers.count {
			if self.tableView(self.tableView, shouldSelectRow: index) {
				self.tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
				return true
			}
		}
		return false
	}

	/// Move the selection to the next selectable row
	///
	/// * Skips any row(s) that identify themselves as 'unselectable'
	/// * If there are no following selectable rows in the table, does not change the current selection
	func selectNextSelectableRow() -> Bool {
		var currentSelection = self.tableView.selectedRow
		while currentSelection < (self.identifiers.count - 1) {
			currentSelection += 1
			if self.tableView(self.tableView, shouldSelectRow: currentSelection) {
				self.tableView.selectRowIndexes(IndexSet(integer: currentSelection), byExtendingSelection: false)
				self.tableView.scrollRowToVisible(currentSelection)
				return true
			}
		}
		return false
	}

	/// Move the selection to the previous selectable row
	///
	/// * Skips any row(s) that identify themselves as 'unselectable'
	/// * If there are no prior selectable rows in the table, does not change the current selection
	func selectPreviousSelectableRow() -> Bool {
		var currentSelection = self.tableView.selectedRow
		while currentSelection > 0 {
			currentSelection -= 1
			if self.tableView(self.tableView, shouldSelectRow: currentSelection) {
				self.tableView.selectRowIndexes(IndexSet(integer: currentSelection), byExtendingSelection: false)
				self.tableView.scrollRowToVisible(currentSelection)
				return true
			}
		}
		return false
	}
}

// MARK: - Handle key events in the results table

extension DSFQuickActionBar {
	class ResultsTableView: NSTableView {
		weak var parent: DSFQuickActionBar.ResultsView?

		override func keyDown(with event: NSEvent) {
			guard let parent = self.parent else { fatalError() }

			if event.keyCode == 0x24 { // kVK_Return {
				parent.rowAction()
			}
			else if event.keyCode == 0x7B { // kVK_LeftArrow
				parent.backAction()
			}
			else if event.modifierFlags.contains(.command),
			        let c = event.characters,
			        let v = Int(c)
			{
				if parent.performShortcutAction(for: v) {
					return
				}
				else {
					super.keyDown(with: event)
				}
			}
			else {
				super.keyDown(with: event)
			}
		}
	}
}

// MARK: - Custom row drawing

private class ResultsRowView: NSTableRowView {
	override func drawSelection(in dirtyRect: NSRect) {
		if selectionHighlightStyle != .none {
			DSFAppearanceManager.AccentColor.setFill()
			let pth = NSBezierPath(roundedRect: self.bounds.insetBy(dx: 4, dy: 2), xRadius: 4, yRadius: 4)
			pth.fill()
		}
	}
}
