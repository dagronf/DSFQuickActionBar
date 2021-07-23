//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI
import DSFQuickActionBar


struct ContentView: View {

	let quickActionBar = DSFQuickActionBar.SwiftUI<MountainViewCell>()
	let searchIcon = DSFQuickActionBar.SearchIcon(
		Image("mountain-template"),
		isTemplate: true)

	@State var selectedMountain: Mountain?

	var body: some View {
		GeometryReader { gp in
			VStack {
				Text("SwiftUI Demo for DSFQuickActionBar").font(.title2)
				Text("SwiftUI currently only supports global positions for the")
				Text("quick action bar due to limitations in the framework")
				Spacer().frame(height: 8)
				Divider()
				Text("Press the button to display a quick action bar")
				HStack {
					Button("Show Quick Action Bar") {
						let frame = gp.frame(in: .global)
						self.quickActionBar.present(
							placeholderText: "Search Mountains",
							searchIcon: searchIcon,
							contentSource: MountainContentSource(
								selectedMountain: $selectedMountain)
						)
					}
				}
				HStack {
					Text("User selected: ")
					Text(selectedMountain?.name ?? "<nothing>")
				}
			}
			.padding()
			.frame(width: 400)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

// MARK: - QuickBar content source

/// A data source for the quick bar that allows searching mountains
class MountainContentSource: DSFQuickActionBarContentSource {

	@Binding var selectedMountain: Mountain?

	init(selectedMountain: Binding<Mountain?>) {
		self._selectedMountain = selectedMountain
	}

	func identifiersForSearch(_ term: String) -> [DSFQuickActionBar.ItemIdentifier] {
		if term.isEmpty { return [] }
		return AllMountains
			.filter { $0.name.localizedCaseInsensitiveContains(term) }
			.sorted(by: { a, b in a.name < b.name })
			.prefix(100)
			.map { $0.identifier }
	}

	func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier) -> RowContent? where RowContent: View {
		guard let mountain = AllMountains.filter({ $0.identifier == identifier }).first else {
			return nil
		}
		return MountainViewCell(name: mountain.name, height: mountain.height) as? RowContent
	}


	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let mountain = AllMountains.filter({ $0.identifier == identifier }).first else {
			return
		}
		selectedMountain = mountain
	}

	func didCancel() {
		selectedMountain = nil
	}
}

