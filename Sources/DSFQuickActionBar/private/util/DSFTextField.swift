//
//  DSFTextField.swift
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

import AppKit
import Foundation

// To allow us to call global objc functions undo/redo using #selector() instead of Selector()
@objc private protocol UndoRedoActionRespondable {
	func undo(_ sender: AnyObject)
	func redo(_ sender: AnyObject)
}

/// A text field that handles cut/copy/paste/undo/redo without having an appropriate menu item handling it
///
/// Thanks [cyrilzakka](https://github.com/dagronf/DSFQuickActionBar/pull/4/files).
internal final class DSFTextField: NSTextField {
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		if
			event.type == .keyDown,
			event.modifierFlags.contains(.command),
			let chars = event.charactersIgnoringModifiers?.lowercased()
		{
			switch chars {
			case "x":
				// Cut
				if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) {
					return true
				}
			case "c":
				// Copy
				if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) {
					return true
				}
			case "v":
				// Paste
				if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) {
					return true
				}
			case "a":
				// Select all
				if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) {
					return true
				}
			case "z":
				if event.modifierFlags.contains(.shift) {
					// Redo (command-shift-z)
					if NSApp.sendAction(#selector(UndoRedoActionRespondable.redo(_:)), to: nil, from: self) {
						return true
					}
				}
				else {
					// Undo (command-z)
					if NSApp.sendAction(#selector(UndoRedoActionRespondable.undo(_:)), to: nil, from: self) {
						return true
					}
				}
			default:
				break
			}
		}
		return super.performKeyEquivalent(with: event)
	}

	override var allowsVibrancy: Bool {
		return true
	}
}
