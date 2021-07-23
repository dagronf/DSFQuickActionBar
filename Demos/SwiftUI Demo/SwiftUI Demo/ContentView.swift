//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI
import DSFQuickActionBar

struct ContentView: View {

	let qab = DSFQuickActionBar.SwiftUI<MountainViewCell>()
	let searchIcon = DSFQuickActionBar.SearchIcon(
		Image("mountain-template"),
		isTemplate: true)

	@State var selectedMountainName: String = ""

	var body: some View {
		VStack {
			Text("SwiftUI Demo for DSFQuickActionBar").font(.title2)
			Text("Press the button to display a quick action bar")
			HStack {
				Button("Show Quick Action Bar") {
					qab.present(
						placeholderText: "Search Mountains",
						searchIcon: searchIcon) { term in
						identifiersForSearch(term)
					}
					rowContent: { identifier in
						viewForIdentifier(identifier)
					}
					action: { identifier in
						didSelectIdentifier(identifier)
					}
				}
			}
			HStack {
				Text("User selected: ")
				Text("\(selectedMountainName)")
			}
		}
		.padding()
		.frame(width: 400)
	}
}

extension ContentView {

	func identifiersForSearch(_ term: String) -> [DSFQuickActionBar.ItemIdentifier] {
		if term.isEmpty { return [] }

		/// Return the item identifiers for the matching mountains
		return AllMountains
			.filter { $0.name.localizedCaseInsensitiveContains(term) }
			.sorted(by: { a, b in a.name < b.name })
			.prefix(100)
			.map { $0.identifier }
	}

	func viewForIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) -> MountainViewCell? {
		guard let mountain = AllMountains.filter({ $0.identifier == identifier }).first else {
			return nil
		}
		return MountainViewCell(name: mountain.name, height: mountain.height)
	}

	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let mountain = AllMountains.filter({ $0.identifier == identifier }).first else {
			return
		}
		selectedMountainName = mountain.name
	}
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

