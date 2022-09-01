//
//  DocoContentView.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 31/8/2022.
//

import SwiftUI
import DSFQuickActionBar

struct DocoContentView: View {

	// Binding to update when the user selects a filter
	@State var selectedFilter: Filter?
	@State var quickActionBarVisible = false

	var body: some View {
		VStack {
			Button("Show Quick Action Bar") {
				quickActionBarVisible = true
			}
			QuickActionBar<Filter, Text>(
				location: .screen,
				visible: $quickActionBarVisible,
				selectedItem: $selectedFilter,
				placeholderText: "Open Quickly...",
				identifiersForSearchTerm: { searchTerm in
					filters__.search(searchTerm)
				},
				rowContent: { filter, searchTerm in
					Text(filter.userPresenting)
				}
			)
		}
	}
}

struct DocoContentView_Previews: PreviewProvider {
	static var previews: some View {
		DocoContentView()
	}
}
