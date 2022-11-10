//
//  ViewController.swift
//  Doco Demo
//
//  Created by Darren Ford on 1/9/2022.
//

import Cocoa
import DSFQuickActionBar

class ViewController: NSViewController {
	let quickActionBar = DSFQuickActionBar()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Set the content source for the quick action bar
		quickActionBar.contentSource = self
	}

	@IBAction func selectFilter(_ sender: Any) {
		// Present the quick action bar
		quickActionBar.present(
			placeholderText: "Search for filters…",
			showKeyboardShortcuts: true
		)
	}
}

extension ViewController: DSFQuickActionBarContentSource {

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTerm searchTerm: String, resultsCallback: @escaping ([AnyHashable]) -> Void) {
		resultsCallback(Filter.search(searchTerm))
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView? {
		guard let filter = item as? Filter else { fatalError() }

		let disabled = filter.name.lowercased().contains("area")

		let tv: NSTextField
		if #available(macOS 10.12, *) {
			tv = NSTextField(labelWithString: filter.userPresenting)
		} else {
			tv = NSTextField()
			tv.stringValue = filter.userPresenting
			tv.isBordered = false
			tv.isBezeled = false
		}
		tv.textColor = disabled ? NSColor.placeholderTextColor : NSColor.textColor

		return InsetsView(tv, inset: 4)
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable) -> Bool {
		guard let filter = item as? Filter else { fatalError() }
		return !filter.name.lowercased().contains("area")
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: AnyHashable) {
		Swift.print("Selected item \(item as? Filter)")
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didActivateItem item: AnyHashable) {
		Swift.print("Activated item \(item as? Filter)")
	}
}

struct Filter: Hashable, CustomStringConvertible {
	let name: String // The name is unique within our dataset, therefore it will be our identifier
	var userPresenting: String { return CIFilter.localizedName(forFilterName: self.name) ?? self.name }
	var description: String { name }

	// All of the available filters
	static var AllFilters: [Filter] = {
		let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
		return filterNames.map { name in Filter(name: name) }
	}()

	// Return filters matching the search term
	static func search(_ searchTerm: String) -> [Filter] {
		if searchTerm.isEmpty { return AllFilters }
		return Filter.AllFilters
			.filter { $0.userPresenting.localizedCaseInsensitiveContains(searchTerm) }
			.sorted(by: { a, b in a.userPresenting < b.userPresenting })
	}
}
