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

	var body: some View {
		//Self._printChanges()
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
				Text(selectedFilter?.description ?? "")
			}
			QuickActionBar<Filter, FilterViewCell>(
				location: location,
				visible: $visible,
				searchTerm: $searchTerm,
				selectedItem: $selectedFilter,
				placeholderText: "Type something (eg. blur)",
				identifiersForSearchTerm: { searchTerm in
					filters__.search(searchTerm)
				},
				viewForIdentifier: { filter, searchTerm in
					FilterViewCell(filter: filter)
				}
			)
			Spacer()
			.onChange(of: showAllIfNoSearchTerm, perform: { newValue in
				filters__.showAllIfEmpty = newValue
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
