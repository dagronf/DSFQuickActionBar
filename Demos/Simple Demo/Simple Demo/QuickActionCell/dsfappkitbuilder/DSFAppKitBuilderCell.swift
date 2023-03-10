//
//  DSFAppKitBuilderCell.swift
//  DSFAppKitBuilderCell
//
//  Created by Darren Ford on 7/8/21.
//

import AppKit
import DSFAppKitBuilder

class DSFAppKitBuilderCell: DSFAppKitBuilderView, DSFAppKitBuilderViewHandler {
	let filter: Filter
	init(filter: Filter, currentSearch: String) {
		self.filter = filter
		super.init()

		self.element = body
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	lazy var body: Element =
	HStack(spacing: 8) {
		ImageView()
			.image(NSImage(named: "filter-funnel")!)
			.size(width: 36, height: 36, priority: .required)
		VStack(spacing: 2, alignment: .leading) {
			Label(filter.userPresenting)
				.font(NSFont.systemFont(ofSize: 18))
				.lineBreakMode(.byTruncatingTail)
				.horizontalPriorities(compressionResistance: 100)
			Label(filter.description)
				.font(NSFont.systemFont(ofSize: 11))
				.textColor(.placeholderTextColor)
				.lineBreakMode(.byTruncatingTail)
				.horizontalPriorities(compressionResistance: 100)
		}
	}
	.edgeInsets(top: 4, left: 0, bottom: 4, right: 0)
}
