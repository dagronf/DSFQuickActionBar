//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI
import DSFQuickActionBar

struct ContentView: View {

	@State var searchTerm = ""
	@State var visible = false
	@State var selectedFilter: Filter?
	@State var location: QuickActionBarLocation = .screen
	@State var showAllIfNoSearchTerm = true
	@State var selectedItem: DSFQuickActionBar.ItemIdentifier?

	var body: some View {
		Self._printChanges()
		_ = showAllIfNoSearchTerm
		return VStack(spacing: 12) {
			VStack(spacing: 12) {
				Text("SwiftUI Demo for DSFQuickActionBar").font(.title2)

				HStack {
					Button("Show for window") {
						visible = true
						location = .window
					}
					Button("Show for screen") {
						visible = true
						location = .screen
					}
				}

				Toggle(isOn: $showAllIfNoSearchTerm, label: {
					Text("Show all items if search term is empty")
				})
			}
			Divider()
			VStack {
				HStack {
					Text("Current search term:")
					TextField("The search term", text: $searchTerm)
				}
				Text("User selected: '\(selectedFilter?.userPresenting ?? "<none>")'")
				Text(selectedItem?.description ?? "")
			}
			QuickActionBar<FilterViewCell>(
				location: location,
				visible: $visible,
				searchTerm: $searchTerm,
				selectedItem: $selectedItem,
				placeholderText: "Type something (eg. blur)",
				identifiersForSearchTerm: { searchTerm in
					filterContent.identifiersForSearch(searchTerm)
				},
				rowContent: { identifier, searchTerm in
					filterContent.viewForIdentifier(identifier, searchTerm: searchTerm)
				}
			)
			Spacer()
			.onChange(of: showAllIfNoSearchTerm, perform: { newValue in
				filterContent.showAllIfEmpty = newValue
			})
			.onChange(of: selectedItem, perform: { newValue in
				selectedFilter = filterContent.filter(for: newValue)
			})
		}
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

// MARK: - QuickBar content source

let filterContent = CoreImageFiltersContentSource()

/// A data source for the quick bar that allows searching core image filters
class CoreImageFiltersContentSource {

	var showAllIfEmpty: Bool = true

	func identifiersForSearch(_ searchTerm: String) -> [DSFQuickActionBar.ItemIdentifier] {
		if searchTerm.isEmpty {
			if showAllIfEmpty {
				return AllFilters.map { $0.id }
			}
			else {
				return []
			}
		}

		return AllFilters
			.filter { $0.userPresenting.localizedCaseInsensitiveContains(searchTerm) }
			.sorted(by: { a, b in a.userPresenting < b.userPresenting } )
			.map { $0.id }
	}

	// Return a filter cell
	func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier, searchTerm: String) -> RowContent? where RowContent: View {
		guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
			return nil
		}
		return FilterViewCell(filter: filter) as? RowContent
	}

	func filter(for identifier: DSFQuickActionBar.ItemIdentifier?) -> Filter? {
		if let identifier {
			return AllFilters.filter({ $0.id == identifier }).first
		}
		return nil
	}
}
