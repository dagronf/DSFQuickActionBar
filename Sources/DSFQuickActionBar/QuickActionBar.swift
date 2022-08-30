//
//  File.swift
//  
//
//  Created by Darren Ford on 30/8/2022.
//

import Foundation
import SwiftUI

#if os(macOS) && canImport(SwiftUI)

/// Delegate for a QSFQuickActionBar instance
public protocol QuickActionBarContentSource: NSObjectProtocol {

	/// Called when the specified identifier is 'activated' (double clicked, return key pressed etc)
	func quickActionBar(didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier)

	/// Called when the quick action bar was dismissed without selecting an item (optional)
	func quickActionBarDidCancel()
}



@available(macOS 10.15, *)
public final class QuickActionBar<RowContent: View>: NSObject, NSViewRepresentable {

	private let localToWindow: Bool
	private let placeholderText: String?
	private let rowContent: (DSFQuickActionBar.ItemIdentifier, String) -> RowContent?

	private var _identifiersForSearchTerm: (String) -> [DSFQuickActionBar.ItemIdentifier]
	private var _didSelectItem: (DSFQuickActionBar.ItemIdentifier) -> Void

	@Binding var visible: Bool
	@Binding var selectedItem: DSFQuickActionBar.ItemIdentifier?
	@Binding var searchText: String

	public init(
		localToWindow: Bool = false,
		visible: Binding<Bool>,
		searchTerm: Binding<String> = .constant(""),
		selectedItem: Binding<DSFQuickActionBar.ItemIdentifier?>,
		placeholderText: String? = DSFQuickActionBar.DefaultPlaceholderString,
		identifiersForSearchTerm: @escaping (String) -> [DSFQuickActionBar.ItemIdentifier],
		onSelectItem: @escaping (DSFQuickActionBar.ItemIdentifier) -> Void,
		rowContent: @escaping (DSFQuickActionBar.ItemIdentifier, String) -> RowContent?
	) {
		self._visible = visible
		self.rowContent = rowContent
		self.localToWindow = localToWindow
		self.placeholderText = placeholderText
		self._searchText = searchTerm
		self._selectedItem = selectedItem
		self._identifiersForSearchTerm = identifiersForSearchTerm
		self._didSelectItem = onSelectItem
		super.init()
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public func makeNSView(context: Context) -> NSView {
		let c = NSView()
		c.translatesAutoresizingMaskIntoConstraints = false
		c.widthAnchor.constraint(equalToConstant: 0).isActive = true
		c.heightAnchor.constraint(equalToConstant: 0).isActive = true
		return c
	}

	public func updateNSView(_ nsView: NSView, context: Context) {
		let window = nsView.window

		// Grab the nsview object
		let quickAction = context.coordinator.quickActionBar
		quickAction.contentSource = self

		Swift.print(":: update view -> \(visible) : \(quickAction.isPresenting)")

		if self.visible {
			if quickAction.isPresenting {
				// We are already visible
				Swift.print(":: Already visible, ignoring")
				return
			}

			// We need to present the quick action bar

			if let window, localToWindow {
				quickAction.present(
					in: window,
					placeholderText: self.placeholderText,
					initialSearchText: searchText
				) { [weak self] in
					Swift.print(":: quick action bar closed")
					self?.visible = false
				}
			}
			else {
				quickAction.presentOnMainScreen(
					placeholderText: self.placeholderText,
					initialSearchText: searchText,
					width: 800
				) { [weak self] in
					Swift.print(":: quick action bar closed")
					self?.visible = false
				}
			}
		}
		else {
			// We _were_ visible, but we now want to close it
			Swift.print(":: close the quick action bar")
			quickAction.cancel()
		}
	}

	public typealias NSViewType = NSView
}

@available(macOS 10.15, *)
extension QuickActionBar: DSFQuickActionBarContentSource {
	public func quickActionBar(
		_ quickActionBar: DSFQuickActionBar,
		identifiersForSearchTerm searchTerm: String
	) -> [DSFQuickActionBar.ItemIdentifier] {
		DispatchQueue.main.async { [weak self] in self?.searchText = searchTerm }
		return self._identifiersForSearchTerm(searchTerm)
	}

	public func quickActionBar(
		_ quickActionBar: DSFQuickActionBar,
		didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier
	) {
		self.selectedItem = identifier
		self._didSelectItem(identifier)
	}

	public func quickActionBar(
		_ quickActionBar: DSFQuickActionBar,
		viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier,
		searchTerm: String
	) -> NSView? {
		if let view = self.rowContent(identifier, searchTerm) {
			return NSHostingView<RowContent>(rootView: view)
		}
		return nil
	}

	public func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		self.visible = false
	}
}

@available(macOS 10.15, *)
public extension QuickActionBar {
	class Coordinator: NSObject {
		// Use the coordinator to hold on to the AppKit ui object
		let quickActionBar = DSFQuickActionBar()
	}
}

#endif
