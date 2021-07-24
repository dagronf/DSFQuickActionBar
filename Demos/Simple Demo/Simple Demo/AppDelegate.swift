//
//  AppDelegate.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Cocoa
import DSFQuickActionBar

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!

	@IBOutlet var resultLabel: NSTextField!

	var currentSearch = ""

	lazy var quickActionBar: DSFQuickActionBar = {
		let b = DSFQuickActionBar()
		b.contentSource = self
		return b
	}()

	func applicationDidFinishLaunching(_: Notification) {
		// Insert code here to initialize your application
		self.resultLabel.stringValue = ""
	}

	func applicationWillTerminate(_: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
		return true
	}

	@IBAction func showQuickActions(_: Any) {
		self.resultLabel.stringValue = ""
		self.quickActionBar.present(
			in: self.window,
			placeholderText: "Search Filters",
			searchImage: NSImage(named: "filter-icon")!
		)
	}

	@IBAction func showGlobalQuickActions(_: Any) {
		self.resultLabel.stringValue = ""
		self.quickActionBar.presentOnMainScreen(
			placeholderText: "Search Filters Globally",
			width: 800
		)
	}

	var loadingType = 1
	@IBAction func setLoadingType(_ sender: NSButton) {
		self.loadingType = sender.tag
	}

	@objc dynamic var showAllWhenEmpty: Bool = false

}

extension AppDelegate: DSFQuickActionBarContentSource {
	func quickActionBar(_: DSFQuickActionBar, identifiersForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {

		// Display ALL items when there's no search term
		if showAllWhenEmpty && term.isEmpty {
			return AllFilters
				.sorted { a, b in a.userPresenting < b.userPresenting }
				.map { $0.id }
		}

		self.currentSearch = term

		if term.isEmpty {
			return []
		}

		/// Return the item identifiers for the matching mountains
		let matches = AllFilters
			.filter { $0.userPresenting.localizedCaseInsensitiveContains(term) }
			.sorted(by: { a, b in a.userPresenting < b.userPresenting })
			.map { $0.id }

		return matches
	}

	func quickActionBar(_: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
		// Find the item with the specified item identifier
		guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
			return nil
		}

		if self.loadingType == 2 {
			return DynamicResultCell(filter: filter)
		}
		else if self.loadingType == 1 {
			return self.XIBResultCell(filter: filter)
		}

		fatalError()
	}

	func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let mountain = AllFilters.filter({ $0.id == identifier }).first else {
			fatalError()
		}
		self.resultLabel.stringValue = "Quick Action Bar selected '\(mountain.name)'"
	}

	func quickActionBarDidCancel(_: DSFQuickActionBar) {
		self.resultLabel.stringValue = "Quick Action Bar cancelled"
	}
}

// MARK: - Load result cell from XIB

extension AppDelegate {
	func XIBResultCell(filter: Filter) -> NSView {
		let item = FilterCellQuickView()

		let searchText = self.currentSearch.lowercased()
		let attName = NSMutableAttributedString(string: filter.userPresenting)

		if self.currentSearch.count > 0,
			let r = filter.userPresenting.lowercased().range(of: searchText)
		{
			let ran = NSRange(r, in: filter.userPresenting)
			attName.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: ran)
			attName.addAttribute(.font, value: NSFont.systemFont(ofSize: item.actionName.font?.pointSize ?? 23,
																				  weight: .bold), range: ran)
			item.actionName.attributedStringValue = attName
		}
		else {
			item.actionName.attributedStringValue = attName
		}
		item.actionDescription.stringValue = filter.description
		return item
	}
}

// MARK: - Create result cell

extension AppDelegate {
	func DynamicResultCell(filter: Filter) -> NSView {
		let stack = NSStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.orientation = .horizontal

		let im = self.makeImage()
		stack.addArrangedSubview(im)

		let textstack = NSStackView()
		textstack.spacing = 2
		textstack.alignment = .leading
		textstack.translatesAutoresizingMaskIntoConstraints = false
		textstack.orientation = .vertical

		let t1 = NSTextField(labelWithString: filter.userPresenting)
		t1.translatesAutoresizingMaskIntoConstraints = false
		t1.font = NSFont.systemFont(ofSize: 24)
		textstack.addArrangedSubview(t1)

		let t2 = NSTextField(labelWithString: filter.description)
		t2.translatesAutoresizingMaskIntoConstraints = false
		t2.font = NSFont.systemFont(ofSize: 12)
		t2.textColor = NSColor.placeholderTextColor
		textstack.addArrangedSubview(t2)

		stack.addArrangedSubview(textstack)

		return stack
	}

	private func makeImage() -> NSImageView {
		let imageView = NSImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
		imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 48))
		imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 48))
		imageView.imageScaling = .scaleProportionallyUpOrDown

		let image = NSImage(named: "filter-colorful")!
		imageView.image = image

		return imageView
	}
}
