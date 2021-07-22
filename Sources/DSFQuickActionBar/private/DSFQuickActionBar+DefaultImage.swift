//
//  DSFQuickActionBar+DefaultImage.swift
//  DSFQuickActionBar
//
//  Created by Darren Ford on 22/7/21
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AppKit

extension DSFQuickActionBar {
	// Generate a default image for the search field
	static func DefaultSearchImage() -> NSImage {
		return NSImage.CreateARGB32(width: 64, height: 64) {
			// Generated using PaintCode
			let textPath = NSBezierPath()
			textPath.move(to: NSPoint(x: 27.52, y: 21.25))
			textPath.curve(to: NSPoint(x: 33.55, y: 22.46), controlPoint1: NSPoint(x: 29.66, y: 21.25), controlPoint2: NSPoint(x: 31.67, y: 21.65))
			textPath.curve(to: NSPoint(x: 38.5, y: 25.78), controlPoint1: NSPoint(x: 35.43, y: 23.26), controlPoint2: NSPoint(x: 37.08, y: 24.37))
			textPath.curve(to: NSPoint(x: 41.84, y: 30.69), controlPoint1: NSPoint(x: 39.92, y: 27.2), controlPoint2: NSPoint(x: 41.04, y: 28.84))
			textPath.curve(to: NSPoint(x: 43.06, y: 36.64), controlPoint1: NSPoint(x: 42.65, y: 32.54), controlPoint2: NSPoint(x: 43.06, y: 34.52))
			textPath.curve(to: NSPoint(x: 41.84, y: 42.58), controlPoint1: NSPoint(x: 43.06, y: 38.74), controlPoint2: NSPoint(x: 42.65, y: 40.72))
			textPath.curve(to: NSPoint(x: 38.5, y: 47.5), controlPoint1: NSPoint(x: 41.04, y: 44.44), controlPoint2: NSPoint(x: 39.92, y: 46.08))
			textPath.curve(to: NSPoint(x: 33.55, y: 50.84), controlPoint1: NSPoint(x: 37.08, y: 48.92), controlPoint2: NSPoint(x: 35.43, y: 50.03))
			textPath.curve(to: NSPoint(x: 27.52, y: 52.06), controlPoint1: NSPoint(x: 31.67, y: 51.65), controlPoint2: NSPoint(x: 29.66, y: 52.06))
			textPath.curve(to: NSPoint(x: 21.51, y: 50.84), controlPoint1: NSPoint(x: 25.4, y: 52.06), controlPoint2: NSPoint(x: 23.4, y: 51.65))
			textPath.curve(to: NSPoint(x: 16.55, y: 47.5), controlPoint1: NSPoint(x: 19.63, y: 50.03), controlPoint2: NSPoint(x: 17.97, y: 48.92))
			textPath.curve(to: NSPoint(x: 13.2, y: 42.58), controlPoint1: NSPoint(x: 15.13, y: 46.08), controlPoint2: NSPoint(x: 14.01, y: 44.44))
			textPath.curve(to: NSPoint(x: 11.99, y: 36.64), controlPoint1: NSPoint(x: 12.4, y: 40.72), controlPoint2: NSPoint(x: 11.99, y: 38.74))
			textPath.curve(to: NSPoint(x: 13.2, y: 30.69), controlPoint1: NSPoint(x: 11.99, y: 34.52), controlPoint2: NSPoint(x: 12.4, y: 32.54))
			textPath.curve(to: NSPoint(x: 16.55, y: 25.78), controlPoint1: NSPoint(x: 14.01, y: 28.84), controlPoint2: NSPoint(x: 15.13, y: 27.2))
			textPath.curve(to: NSPoint(x: 21.51, y: 22.46), controlPoint1: NSPoint(x: 17.97, y: 24.37), controlPoint2: NSPoint(x: 19.63, y: 23.26))
			textPath.curve(to: NSPoint(x: 27.52, y: 21.25), controlPoint1: NSPoint(x: 23.4, y: 21.65), controlPoint2: NSPoint(x: 25.4, y: 21.25))
			textPath.close()
			textPath.move(to: NSPoint(x: 27.52, y: 16.31))
			textPath.curve(to: NSPoint(x: 19.56, y: 17.88), controlPoint1: NSPoint(x: 24.7, y: 16.31), controlPoint2: NSPoint(x: 22.04, y: 16.83))
			textPath.curve(to: NSPoint(x: 13.01, y: 22.28), controlPoint1: NSPoint(x: 17.08, y: 18.93), controlPoint2: NSPoint(x: 14.9, y: 20.4))
			textPath.curve(to: NSPoint(x: 8.59, y: 28.77), controlPoint1: NSPoint(x: 11.12, y: 24.15), controlPoint2: NSPoint(x: 9.65, y: 26.32))
			textPath.curve(to: NSPoint(x: 7, y: 36.64), controlPoint1: NSPoint(x: 7.53, y: 31.22), controlPoint2: NSPoint(x: 7, y: 33.84))
			textPath.curve(to: NSPoint(x: 8.59, y: 44.54), controlPoint1: NSPoint(x: 7, y: 39.46), controlPoint2: NSPoint(x: 7.53, y: 42.09))
			textPath.curve(to: NSPoint(x: 13.02, y: 51.02), controlPoint1: NSPoint(x: 9.65, y: 46.99), controlPoint2: NSPoint(x: 11.13, y: 49.15))
			textPath.curve(to: NSPoint(x: 19.58, y: 55.41), controlPoint1: NSPoint(x: 14.92, y: 52.89), controlPoint2: NSPoint(x: 17.1, y: 54.35))
			textPath.curve(to: NSPoint(x: 27.52, y: 57), controlPoint1: NSPoint(x: 22.05, y: 56.47), controlPoint2: NSPoint(x: 24.7, y: 57))
			textPath.curve(to: NSPoint(x: 35.49, y: 55.41), controlPoint1: NSPoint(x: 30.35, y: 57), controlPoint2: NSPoint(x: 33, y: 56.47))
			textPath.curve(to: NSPoint(x: 42.04, y: 51.02), controlPoint1: NSPoint(x: 37.97, y: 54.35), controlPoint2: NSPoint(x: 40.15, y: 52.89))
			textPath.curve(to: NSPoint(x: 46.46, y: 44.53), controlPoint1: NSPoint(x: 43.93, y: 49.15), controlPoint2: NSPoint(x: 45.4, y: 46.99))
			textPath.curve(to: NSPoint(x: 48.05, y: 36.64), controlPoint1: NSPoint(x: 47.52, y: 42.07), controlPoint2: NSPoint(x: 48.05, y: 39.44))
			textPath.curve(to: NSPoint(x: 46.46, y: 28.77), controlPoint1: NSPoint(x: 48.05, y: 33.84), controlPoint2: NSPoint(x: 47.52, y: 31.22))
			textPath.curve(to: NSPoint(x: 42.04, y: 22.28), controlPoint1: NSPoint(x: 45.4, y: 26.32), controlPoint2: NSPoint(x: 43.93, y: 24.15))
			textPath.curve(to: NSPoint(x: 35.49, y: 17.88), controlPoint1: NSPoint(x: 40.15, y: 20.4), controlPoint2: NSPoint(x: 37.97, y: 18.93))
			textPath.curve(to: NSPoint(x: 27.52, y: 16.31), controlPoint1: NSPoint(x: 33, y: 16.83), controlPoint2: NSPoint(x: 30.35, y: 16.31))
			textPath.close()
			textPath.move(to: NSPoint(x: 53.57, y: 7))
			textPath.curve(to: NSPoint(x: 52.26, y: 7.23), controlPoint1: NSPoint(x: 53.12, y: 7), controlPoint2: NSPoint(x: 52.69, y: 7.08))
			textPath.curve(to: NSPoint(x: 51.12, y: 7.99), controlPoint1: NSPoint(x: 51.83, y: 7.39), controlPoint2: NSPoint(x: 51.45, y: 7.64))
			textPath.line(to: NSPoint(x: 37.23, y: 21.72))
			textPath.line(to: NSPoint(x: 42.22, y: 26.56))
			textPath.line(to: NSPoint(x: 56.02, y: 12.83))
			textPath.curve(to: NSPoint(x: 56.76, y: 11.72), controlPoint1: NSPoint(x: 56.36, y: 12.52), controlPoint2: NSPoint(x: 56.6, y: 12.15))
			textPath.curve(to: NSPoint(x: 57, y: 10.43), controlPoint1: NSPoint(x: 56.92, y: 11.3), controlPoint2: NSPoint(x: 57, y: 10.87))
			textPath.curve(to: NSPoint(x: 56.57, y: 8.67), controlPoint1: NSPoint(x: 57, y: 9.78), controlPoint2: NSPoint(x: 56.86, y: 9.2))
			textPath.curve(to: NSPoint(x: 55.35, y: 7.44), controlPoint1: NSPoint(x: 56.28, y: 8.15), controlPoint2: NSPoint(x: 55.88, y: 7.74))
			textPath.curve(to: NSPoint(x: 53.57, y: 7), controlPoint1: NSPoint(x: 54.83, y: 7.15), controlPoint2: NSPoint(x: 54.24, y: 7))
			textPath.close()
			NSColor.black.setFill()
			textPath.fill()
		}
	}
}
