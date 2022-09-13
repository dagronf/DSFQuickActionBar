//
//  FilterCellQuickView.swift
//  DSFQuickBar
//
//  Created by Darren Ford on 21/7/21.
//

import AppKit

func XIBResultCell(filter: Filter, currentSearch: String) -> FilterCellQuickView {
	let item = FilterCellQuickView()

	let searchText = currentSearch.lowercased()
	let attName = NSMutableAttributedString(string: filter.userPresenting)

	if currentSearch.count > 0,
		let r = filter.userPresenting.lowercased().range(of: searchText)
	{
		let ran = NSRange(r, in: filter.userPresenting)
		attName.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: ran)
		attName.addAttribute(.font, value: NSFont.systemFont(ofSize: item.actionName.font?.pointSize ?? 23,
																			  weight: .bold), range: ran)
		item.actionName.attributedStringValue = attName
	}
	else {
		item.actionName.attributedStringValue = attName
	}
	item.actionDescription.stringValue = filter.description
	return item
}

class FilterCellQuickView: NSTableCellView {

	@IBOutlet var contentView: NSView!
	@IBOutlet weak var actionName: NSTextField!
	@IBOutlet weak var actionDescription: NSTextField!

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setup()
	}

	private func setup() {
		let bundle = Bundle(for: type(of: self))
		let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
		nib.instantiate(withOwner: self, topLevelObjects: nil)

		addSubview(contentView)

		self.addConstraints(
			NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
													 options: .alignAllCenterX,
													 metrics: nil, views: ["view": contentView!]))

		self.addConstraints(
			NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
													 options: .alignAllCenterY,
													 metrics: nil, views: ["view": contentView!]))
	}
}
