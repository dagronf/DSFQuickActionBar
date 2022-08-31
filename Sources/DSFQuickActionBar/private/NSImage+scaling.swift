//
//  NSImage+scaling.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation
import AppKit

public extension NSImage {
	/// Scale the image proportionally to fit to the target size, returning a new image
	func scaleImageProportionally(to targetSize: NSSize) -> NSImage? {
		guard let rep = self.representations.first else {
			return nil
		}
		
		let origSize = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
		
		let ddx: CGFloat = targetSize.width / origSize.width
		let ddy: CGFloat = targetSize.height / origSize.height
		
		let scale = min(ddx, ddy)
		
		let newRect = NSRect(x: 0, y: 0, width: origSize.width * scale, height: origSize.height * scale)
		
		let representation = NSBitmapImageRep(
			bitmapDataPlanes: nil,
			pixelsWide: Int(newRect.width),
			pixelsHigh: Int(newRect.height),
			bitsPerSample: 8,
			samplesPerPixel: 4,
			hasAlpha: true,
			isPlanar: false,
			colorSpaceName: .calibratedRGB,
			bytesPerRow: 0,
			bitsPerPixel: 0
		)
		
		representation?.size = newRect.size
		
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: representation!)
		self.draw(in: newRect, from: NSZeroRect, operation: .copy, fraction: 1.0)
		NSGraphicsContext.restoreGraphicsState()
		
		let newImage = NSImage(size: newRect.size)
		newImage.addRepresentation(representation!)
		
		return newImage
	}
}
