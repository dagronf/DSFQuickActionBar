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

// MARK: - NSImage proportional scaling

public extension NSImage {
	/// Generate a new image with equal dimensions by scaling proportionally and centering within the target
	/// - Parameter dimension: The final dimension of the image
	/// - Returns: The scaled image, or nil if an error occurs
	@inlinable func scaleImageProportionally(to dimension: Double) -> NSImage? {
		self.scaleImageProportionally(to: NSSize(width: dimension, height: dimension))
	}

	/// Generate a new image with a defined size by scaling proportionally and centering within the target
	/// - Parameter targetSize: The final size of the image to generate
	/// - Returns: The scaled image, or nil if an error occurs
	func scaleImageProportionally(to targetSize: NSSize) -> NSImage? {
		// Get a bitmap representation of the image.
		guard let tiff = self.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else {
			return nil
		}

		// The size of the original image
		let origSize = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)

		// The scaling required to draw the representation in the target rect
		let ddx: CGFloat = targetSize.width / origSize.width
		let ddy: CGFloat = targetSize.height / origSize.height
		let scale = min(ddx, ddy)

		// The size of _this_ image scaled to fit within the target size
		let scaledImageSize = CGSize(width: origSize.width * scale, height: origSize.height * scale)

		// Create a new bitmap representation with the target size
		guard let representation = NSBitmapImageRep(
			bitmapDataPlanes: nil,
			pixelsWide: Int(targetSize.width),
			pixelsHigh: Int(targetSize.height),
			bitsPerSample: 8,
			samplesPerPixel: 4,
			hasAlpha: true,
			isPlanar: false,
			colorSpaceName: .calibratedRGB,
			bytesPerRow: 0,
			bitsPerPixel: 0
		) else {
			return nil
		}

		representation.size = targetSize

		let xOffset: Double = (targetSize.width - scaledImageSize.width) / 2.0
		let yOffset: Double = (targetSize.height - scaledImageSize.height) / 2.0

		// Write the image into the new image rep
		do {
			NSGraphicsContext.saveGraphicsState()
			NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: representation)
			self.draw(
				in: NSRect(
					x: xOffset,
					y: yOffset,
					width: scaledImageSize.width,
					height: scaledImageSize.height
				),
				from: .zero,
				operation: .copy,
				fraction: 1.0
			)
			NSGraphicsContext.restoreGraphicsState()
		}

		let newImage = NSImage(size: targetSize)
		newImage.addRepresentation(representation)
		return newImage
	}
}
