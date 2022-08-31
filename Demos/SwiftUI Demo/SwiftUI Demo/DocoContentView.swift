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
	@State var selectedItem: DSFQuickActionBar.ItemIdentifier?
	@State var quickActionBarVisible = false

	var body: some View {
		VStack {
			Button("Show Quick Action Bar") {
				quickActionBarVisible = true
			}
			QuickActionBar<FilterViewCell>(
				location: .screen,
				visible: $quickActionBarVisible,
				selectedItem: $selectedItem,
				placeholderText: "Open Quickly...",
				identifiersForSearchTerm: { searchTerm in
					filterContent.identifiersForSearch(searchTerm)
				},
				rowContent: { identifier, searchTerm in
					filterContent.viewForIdentifier(identifier, searchTerm: searchTerm)
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
