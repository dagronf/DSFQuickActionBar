//
//  FilterCellQuickViewSwiftUI.swift
//  FilterCellQuickViewSwiftUI
//
//  Created by Darren Ford on 27/7/21.
//

import SwiftUI

func SwiftUIResultCell(filter: Filter, currentSearch: String) -> NSView {
	let uiView = FilterCellQuickViewSwiftUI(title: filter.userPresenting, description: filter.description)
	let hosting = NSHostingView(rootView: uiView)
	return hosting
}

struct FilterCellQuickViewSwiftUI: View {

	let title: String
	let description: String

	var body: some View {

		HStack {
			Image("filter-color").resizable()
				.frame(width: 32, height: 32)
			VStack {
				Text(title)
					.font(.title)
					.multilineTextAlignment(.leading)
				Text(description).italic()
					.multilineTextAlignment(.leading)
					.foregroundColor(.gray)
			}
			.frame(alignment: .leading)
		}
	}
}

struct FilterCellQuickViewSwiftUI_Previews: PreviewProvider {
	static var previews: some View {
		FilterCellQuickViewSwiftUI(
			title: "Box Blur", description: "Do a box blur")
	}
}
