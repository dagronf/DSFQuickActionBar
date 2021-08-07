//
//  DSFAppKitBuilderCell.swift
//  DSFAppKitBuilderCell
//
//  Created by Darren Ford on 7/8/21.
//

import AppKit
import DSFAppKitBuilder

func DSFAppKitBuilderView(filter: Filter, currentSearch: String) -> NSView {
	return DSFAppKitBuilderCell(filter: filter).nsView
}


private func DSFAppKitBuilderCell(filter: Filter) -> Element {
	return
		HStack(spacing: 4) {
			ImageView()
				.image(NSImage(named: "filter-color")!)
				.size(width: 42, height: 42, priority: .required)
			VStack(spacing: 2, alignment: .leading) {
				Label(filter.userPresenting)
					.font(NSFont.systemFont(ofSize: 24))
					.lineBreakMode(.byTruncatingTail)
					.horizontalPriorities(compressionResistance: 100)
				Label(filter.description)
					.font(NSFont.systemFont(ofSize: 12))
					.textColor(.placeholderTextColor)
					.lineBreakMode(.byTruncatingTail)
					.horizontalPriorities(compressionResistance: 100)
			}
		}
		.edgeInsets(NSEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
}
