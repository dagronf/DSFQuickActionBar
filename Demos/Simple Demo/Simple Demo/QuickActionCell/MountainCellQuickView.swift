//
//  MountainCellQuickView.swift
//  DSFQuickBar
//
//  Created by Darren Ford on 21/7/21.
//

import AppKit

class MountainCellQuickView: NSView {

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
