//
//  FilterCellQuickViewSwiftUI.swift
//  FilterCellQuickViewSwiftUI
//
//  Created by Darren Ford on 27/7/21.
//

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
func SwiftUIResultCell(filter: Filter, currentSearch: String) -> NSView {
	let uiView = FilterCellQuickViewSwiftUI(title: filter.userPresenting, description: filter.description)
	let hosting = NSHostingView(rootView: uiView)
	return hosting
}

@available(macOS 10.15.0, *)
struct FilterCellQuickViewSwiftUI: View {

	let title: String
	let description: String

	var body: some View {

		HStack {
			Image("filter-color").resizable()
				.frame(width: 32, height: 32)
			VStack(alignment: .leading) {
				HStack {
					Text(title)
						.font(.title)
						.multilineTextAlignment(.leading)
					Spacer()
				}
				HStack {
					Text(description).italic()
						.multilineTextAlignment(.leading)
						.foregroundColor(.gray)
					Spacer()
				}
			}
		}
	}
}

@available(macOS 10.15.0, *)
struct FilterCellQuickViewSwiftUI_Previews: PreviewProvider {
	static var previews: some View {
		FilterCellQuickViewSwiftUI(
			title: "Accordion Fold Transition",
			description: "Transitions from one image to another of a differing dimensions by unfolding.")
	}
}

#endif
