//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI
import DSFQuickActionBar


struct ContentView: View {

	//let quickActionBar = DSFQuickActionBar.SwiftUI<FilterViewCell>()
	let searchIcon = DSFQuickActionBar.SearchIcon(
		Image("filter-icon"),
		isTemplate: true)

	@State var searchTerm = ""
	@State var visible = false
	@State var selectedFilter: Filter?
	@State var localToWindow = true
	@State var showAllIfNoSearchTerm: Bool = true
	@State var selectedItem: DSFQuickActionBar.ItemIdentifier?

	var body: some View {
		Self._printChanges()
		return VStack {
			Text("SwiftUI Demo for DSFQuickActionBar").font(.title2)
			Text("SwiftUI currently only supports global positions for the")
			Text("quick action bar due to limitations in the framework")
			Spacer().frame(height: 8)
			Divider()
			Text("Press the button to display a quick action bar")
			VStack {
				Toggle(isOn: $showAllIfNoSearchTerm, label: {
					Text("Show all items if search term is empty")
				})
				Toggle(isOn: $localToWindow, label: {
					Text("Local to window")
				})

				Button("Show Quick Action Bar") {
					visible = true
				}
			}
			Divider()
			HStack {
				Text("User selected: ")
				Text(selectedItem?.description ?? "")
			}
			QuickActionBar<FilterViewCell>(
				localToWindow: localToWindow,
				visible: $visible,
				searchTerm: $searchTerm,
				selectedItem: $selectedItem,
				placeholderText: "Type something",
				identifiersForSearchTerm: { searchTerm in
					filterContent.identifiersForSearch(searchTerm, showAllIfEmpty: showAllIfNoSearchTerm)
				},
				onSelectItem: { selectedIdentifier in

				},
				rowContent: { identifier, searchTerm in
					filterContent.viewForIdentifier(identifier, searchTerm: searchTerm)
				}
			)

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

	func identifiersForSearch(_ searchTerm: String, showAllIfEmpty: Bool) -> [DSFQuickActionBar.ItemIdentifier] {
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

	func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier, searchTerm: String) -> RowContent? where RowContent: View {
		guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
			return nil
		}
		return FilterViewCell(filter: filter) as? RowContent
	}

//	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
//		guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
//			return EmptyView()
//		}
//		return filter
//	}

	func didCancel() {
		//selectedFilter = nil
	}
}
