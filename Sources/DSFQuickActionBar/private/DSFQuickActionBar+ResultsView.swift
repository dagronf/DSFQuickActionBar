//
//  DSFQuickActionBar+ResultsView.swift
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
	class ResultsView: NSView {
		let scrollView = NSScrollView()
		let tableView = DSFQuickActionBar.ResultsTableView()
		let horizontalView = NSBox()

		var quickActionBar: DSFQuickActionBar!

		var currentSearchTerm: String = ""
		var identifiers: [DSFQuickActionBar.ItemIdentifier] = [] {
			didSet {
				self.isHidden = identifiers.count == 0
				self.tableView.reloadData()
			}
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
		scrollView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300))

		// Scrollview

		scrollView.backgroundColor = NSColor.clear
		scrollView.drawsBackground = false
		scrollView.autohidesScrollers = true
		scrollView.documentView = tableView
		scrollView.hasHorizontalScroller = false
		scrollView.hasVerticalScroller = true

		// Embedded table view

		tableView.addConstraint(NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.quickActionBar.width))

		tableView.dataSource = self
		tableView.delegate = self
		tableView.parent = self
		tableView.headerView = nil

		tableView.backgroundColor = NSColor.clear
		tableView.usesAutomaticRowHeights = true
		tableView.intercellSpacing = NSSize(width: 0, height: 5)

		// Handle double-click on the row
		tableView.doubleAction = #selector(didDoubleClickRow(_:))

		// Table column
		let c = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("searchresult"))
		tableView.addTableColumn(c)
	}
}

// MARK: - Table Data

extension DSFQuickActionBar.ResultsView: NSTableViewDelegate, NSTableViewDataSource {
	func numberOfRows(in _: NSTableView) -> Int {
		return self.identifiers.count
	}

	func tableView(_: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
		// Swift.print("view for \(row)")
		let itemIdentifier = self.identifiers[row]
		return self.quickActionBar.contentSource?.quickActionBar(
			self.quickActionBar,
			viewForIdentifier: itemIdentifier,
			searchTerm: currentSearchTerm)
	}
}

// MARK: - Table Actions

extension DSFQuickActionBar.ResultsView {
	@objc func didDoubleClickRow(_: Any) {
		self.rowAction()
	}

	func rowAction() {
		let selectedRow = self.tableView.selectedRow
		if selectedRow < 0 || selectedRow >= self.identifiers.count {
			return
		}

		let itemIdentifier = self.identifiers[selectedRow]
		self.quickActionBar.contentSource?.quickActionBar(self.quickActionBar, didSelectIdentifier: itemIdentifier)

		self.window?.resignKey()
	}

	func backAction() {
		self.quickActionBar.quickActionBarWindow?.pressedLeftArrowInResultsView()
	}
}

extension DSFQuickActionBar {
	class ResultsTableView: NSTableView {
		weak var parent: DSFQuickActionBar.ResultsView?
		override func keyDown(with event: NSEvent) {
			if let parent = self.parent {
				if event.keyCode == 0x24 { // kVK_Return {
					parent.rowAction()
				}
				else if event.keyCode == 0x7B { // kVK_LeftArrow
					parent.backAction()
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
