//
//  View+GenerateNSImage.swift
//
//  Created by Darren Ford on 23/7/21.
//

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
extension View {
	/// Convert a View to an NSImage
	public func asNSImage(size: CGSize, isTemplate: Bool = false) -> NSImage {
		let hostingView = NSHostingView(rootView: self)
		hostingView.setFrameSize(size)

		let contentRect = CGRect(origin: .zero, size: size)
		guard let brep = hostingView.bitmapImageRepForCachingDisplay(in: contentRect) else {
			return NSImage()
		}
		hostingView.cacheDisplay(in: hostingView.bounds, to: brep)

		let myNSImage = NSImage(size: brep.size)
		myNSImage.addRepresentation(brep)
		myNSImage.isTemplate = isTemplate
		return myNSImage
	}
}

#endif
