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

//	let qab = DSFQuickActionBar()
	@IBOutlet weak var scopeControl: NSPathControl!

	// Use the block-based quick action bar
	let qsab = DSFQuickActionBar.Block<URL, NSTextField>()

	override func viewDidLoad() {
		super.viewDidLoad()
		scopeControl.url = nil
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		qsab.placeholderText = "FauxSpotlight Search"

		qsab.identifiersForSearchTerm = { [weak self] task in
			guard let `self` = self else { return }

			// Cancel an old query
			self.currentQuery?.cancel()
			self.currentQuery = nil

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

		qsab.viewForIdentifier = { item, searchTerm in
			return NSTextField(labelWithString: item.lastPathComponent)
		}

		qsab.didCancel = { [weak self] in
			if let `self` = self {
				self.currentQuery?.cancel()
				self.currentQuery = nil
			}
		}

		qsab.didActivateIdentifier = { item in
			NSWorkspace.shared.selectFile(item.path, inFileViewerRootedAtPath: "~")
		}
	}

	@IBAction func showFauxSpotlight(_ sender: Any) {
		qsab.show(initialSearchTerm: qsab.lastSearchTerm)
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

	var currentQuery: MetadataSearch?
}
