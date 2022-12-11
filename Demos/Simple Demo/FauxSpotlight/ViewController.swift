//
//  ViewController.swift
//  FauxSpotlight
//
//  Created by Darren Ford on 10/11/2022.
//

import Cocoa

import DSFQuickActionBar
import UniformTypeIdentifiers

class ViewController: NSViewController {

	@IBOutlet weak var scopeControl: NSPathControl!

	let qab = DSFQuickActionBar()

	override func viewDidLoad() {
		super.viewDidLoad()
		scopeControl.url = nil
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		// Set the content delegate
		qab.contentSource = self
	}

	@IBAction func showFauxSpotlight(_ sender: Any) {
		qab.present(
			placeholderText: "FauxSpotlight Search",
			initialSearchText: lastSearchTerm
		)
	}

	@IBAction func setScopeFolder(_ sender: Any) {
		let panel = NSOpenPanel()
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		panel.allowsMultipleSelection = false

		panel.beginSheetModal(for: self.view.window!, completionHandler: { [weak self] response in
			guard
				let `self` = self,
				response == NSApplication.ModalResponse.OK,
				let url = panel.url
			else {
				return
			}

			self.scopeControl.url = url
		})
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	var lastSearchTerm = ""
	var currentQuery: MetadataSearch?
}

extension ViewController: DSFQuickActionBarContentSource {
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTermTask task: DSFQuickActionBar.SearchTask) {
		// Cancel an old query
		self.currentQuery?.cancel()
		self.currentQuery = nil

		self.lastSearchTerm = task.searchTerm

		// Simple cleanup before query
		let searchTerm = task.searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)

		// If the search term is empty, there are no results
		if searchTerm.count == 0 {
			task.complete(with: [])
			return
		}

		// Create a predicate that searches both in the display name and content
		// Note that the constructor for predicate automatically adds '' around any arguments!
		let predicate = NSPredicate(
			format: "kMDItemDisplayName contains[cd] %@ || kMDItemTextContent contains[cd] %@",
			searchTerm, searchTerm)

		let scope: MetadataSearch.Scope = {
			if let s = self.scopeControl.url { return .fileUrl(s) }
			return .userHome
		}()

		// Sort by most recently accessed (like spotlight does)
		let sort = NSSortDescriptor(key: NSMetadataItemFSContentChangeDateKey, ascending: false)

		// Start a new query.
		self.currentQuery = MetadataSearch(
			predicate: predicate,
			scope: [scope],
			sortDescriptors: [sort],
			completionBlock: { [weak self] results in
				if !task.isCancelled {
					task.complete(with: results)
				}
				self?.currentQuery = nil
			}
		)
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView? {
		guard let url = item as? URL else { fatalError() }
		return NSTextField(labelWithString: url.lastPathComponent)
	}

	func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		self.currentQuery?.cancel()
		self.currentQuery = nil
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didActivateItem item: AnyHashable) {
		guard let url = item as? URL else { fatalError() }
		NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "~")
	}

}
