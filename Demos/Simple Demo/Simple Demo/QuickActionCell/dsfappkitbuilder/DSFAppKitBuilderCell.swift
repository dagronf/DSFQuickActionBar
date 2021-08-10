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
		
		self.builder = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	lazy var body: Element =
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
	.edgeInsets(bottom: 2)
}
