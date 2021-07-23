//
//  MountainViewCell.swift
//  SwiftUI Demo
//
//  Created by Darren Ford on 23/7/21.
//

import SwiftUI

struct MountainViewCell: View {
	let name: String
	let height: Int
	var description: String {
		return "\(name) description"
	}

	var body: some View {
		HStack {
			Image("mountain").resizable()
				.frame(width: 42, height: 42)
			VStack(alignment: .leading) {
				Text(name).font(.title)
				Text(description).font(.callout).foregroundColor(.gray)
			}
			Spacer()
			Text("\(height)").font(.callout).foregroundColor(.gray)
				.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
		}
	}
}

struct MountainViewCell_Previews: PreviewProvider {
	static var previews: some View {
		MountainViewCell(name: "Mount Everest", height: 10001)
			.frame(width: 300)
	}
}
