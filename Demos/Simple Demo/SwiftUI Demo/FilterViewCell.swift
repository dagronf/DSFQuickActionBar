//
//  FilterViewCell.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI

struct FilterViewCell: View {
	let filter: Filter

	var body: some View {
		HStack {
			Image("filter-color").resizable()
				.frame(width: 42, height: 42)
			VStack(alignment: .leading) {
				HStack {
					Text(filter.userPresenting).font(.title)
					Spacer()
				}
				HStack {
					Text(filter.description).font(.callout).foregroundColor(.gray).italic()
					Spacer()
				}
			}
		}
	}
}

let demoFilter = Filter(name: "CIBlur")

struct FilterViewCell_Previews: PreviewProvider {
	static var previews: some View {
		FilterViewCell(filter: demoFilter)
			.frame(width: 300)
	}
}
