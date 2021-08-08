//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI
import DSFQuickActionBar


struct ContentView: View {

	let quickActionBar = DSFQuickActionBar.SwiftUI<FilterViewCell>()
	let searchIcon = DSFQuickActionBar.SearchIcon(
		Image("filter-icon"),
		isTemplate: true)

	@State var selectedFilter: Filter?
	@State var showAllIfNoSearchTerm: Bool = true

	var body: some View {
		GeometryReader { geom in
			VStack {
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

					Button("Show Quick Action Bar") {
						self.quickActionBar.present(
							placeholderText: "Search Core Image Filters",
							searchIcon: searchIcon,
							contentSource: CoreImageFiltersContentSource(
								selectedFilter: $selectedFilter,
								showAllIfNoSearchTerm: showAllIfNoSearchTerm
							)
						)
					}
				}
				Divider()
				HStack {
					Text("User selected: ")
					Text(selectedFilter?.name ?? "<nothing>")
				}
			}
			.frame(width: 400)
			.padding()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

// MARK: - QuickBar content source

/// A data source for the quick bar that allows searching core image filters
class CoreImageFiltersContentSource: DSFQuickActionBarSwiftUIContentSource {

	@Binding var selectedFilter: Filter?
	let showAllIfNoSearchTerm: Bool

	init(selectedFilter: Binding<Filter?>, showAllIfNoSearchTerm: Bool) {
		self._selectedFilter = selectedFilter
		self.showAllIfNoSearchTerm = showAllIfNoSearchTerm
	}

	func identifiersForSearch(_ searchTerm: String) -> [DSFQuickActionBar.ItemIdentifier] {
		if searchTerm.isEmpty {
			if showAllIfNoSearchTerm {
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

	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
			return
		}
		selectedFilter = filter
	}

	func didCancel() {
		selectedFilter = nil
	}
}
