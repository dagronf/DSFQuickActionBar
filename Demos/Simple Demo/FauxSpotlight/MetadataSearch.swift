//
//  MetadataSearch.swift
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
import os

private let MetadataSearchLog = OSLog(
	subsystem: Bundle.main.bundleIdentifier ?? "MetadataSearch",
	category: "MetadataSearch"
)

@objc class MetadataSearch: NSObject {
	/// Start a metadata search with the given metadata predicate
	/// - Parameters:
	///   - predicate: The NSMetadataQuery predicate
	///   - scope: The scope for the query
	///   - sortDescriptors: The sort descriptors to apply to the result
	///   - operationQueue: The queue to perform the query on
	///   - completionBlock: Called with the URLs of the matching files when the query completes
	init(
		predicate: NSPredicate,
		scope: [Scope] = [.userHome],
		sortDescriptors: [NSSortDescriptor]? = nil,
		operationQueue: OperationQueue = OperationQueue(),
		completionBlock: @escaping ([URL]) -> Void
	) {
		self.completionBlock = completionBlock
		self.startTime = DispatchTime.now()
		super.init()

		os_log("starting …", log: MetadataSearchLog, type: .debug)

		self.query.searchScopes = scope.map { $0.queryScope }
		self.query.operationQueue = operationQueue
		self.query.predicate = predicate

		if let sortDescriptors = sortDescriptors {
			self.query.sortDescriptors = sortDescriptors
		}

		// Set up the query observer
		self.observer = NotificationCenter.default.addObserver(
			forName: NSNotification.Name.NSMetadataQueryDidFinishGathering,
			object: self.query,
			queue: self.query.operationQueue
		) { [weak self] notification in
			self?.queryComplete()
		}

		self.query.start()
	}

	deinit {
		os_log("deinit", log: MetadataSearchLog, type: .debug)
		self.stop()
	}

	/// Cancel the metadata request
	@objc func cancel() {
		os_log("… cancelled", log: MetadataSearchLog, type: .debug)
		self.stop()
	}

	// private

	private var results: [URL] = []

	private let query = NSMetadataQuery()
	private var observer: NSObjectProtocol?
	private var completionBlock: (([URL]) -> Void)?
	private let startTime: DispatchTime
}

extension MetadataSearch {
	/// The scope for the metadata search
	enum Scope {
		/// user home directory
		case userHome
		/// all local mounted volumes + user home (even if remote)
		case localComputer
		/// all user-mounted remote volumes
		case network
		/// all indexed local mounted volumes + user home (even if remote)
		case indexedLocalComputer
		/// all indexed user-mounted remote volumes
		case indexedNetwork

		// -setSearchScopes: will throw an exception if the given array contains a mix of the scope constants below with constants above.

		/// "Documents" subdirectory in the application's Ubiquity container
		case ubiquitousDocuments
		/// application's Ubiquity container, excluding the "Documents" subdirectory
		case ubiquitousData
		/// documents from outside the application's container that are accessible without user interaction. NSMetadataItemURLKey attributes of results are security-scoped NSURLs.
		case ubiquitousExternalDocuments
		/// Specify a local file path
		case filePath(String)
		/// Specify a local file url
		case fileUrl(URL)

		/// Returns the Foundation string type for the scope
		var queryScope: Any {
			switch self {
			case .userHome: return NSMetadataQueryUserHomeScope
			case .localComputer: return NSMetadataQueryLocalComputerScope
			case .network: return NSMetadataQueryNetworkScope
			case .indexedLocalComputer: return NSMetadataQueryIndexedLocalComputerScope
			case .indexedNetwork: return NSMetadataQueryIndexedNetworkScope
			case .ubiquitousDocuments: return NSMetadataQueryUbiquitousDocumentsScope
			case .ubiquitousData: return NSMetadataQueryUbiquitousDataScope
			case .ubiquitousExternalDocuments: return NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope
			case .filePath(let filePath): return filePath as NSString
			case .fileUrl(let fileURL):
				assert(fileURL.isFileURL)
				return fileURL as NSURL
			}
		}
	}
}

private extension MetadataSearch {

	// Called when the query has finished its initial gathering phase
	func queryComplete() {
		self.observer = nil

		var results: [URL] = []

		if self.query.isStopped == false {
			self.query.stop()
			for index in 0 ..< self.query.resultCount {
				let item = self.query.result(at: index) as! NSMetadataItem
				if let path = item.value(forAttribute: kMDItemPath as String) as? String {
					let url = URL(fileURLWithPath: path)
					results.append(url)
				}
			}
		}

		let endTime = DispatchTime.now()
		self.completionBlock?(results)

		os_log("… complete in %ld ms", log: MetadataSearchLog, type: .debug, (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000)
	}

	private func stop() {
		if let o = self.observer {
			NotificationCenter.default.removeObserver(o)
			self.observer = nil
		}
		self.completionBlock = nil
		self.query.stop()
	}
}

// MARK: - Basic metadata search types

// Some help
// - https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/SpotlightQuery/Concepts/QueryingMetadata.html#//apple_ref/doc/uid/TP40001848-CJBEJBHH
// - https://metaredux.com/posts/2019/12/22/mdfind.html
// - https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html#//apple_ref/doc/uid/TP40001793-SW1

/// A simple metadata search for text content
class TextContentMetadataSearch: MetadataSearch {
	@inlinable convenience init(
		_ searchTerm: String,
		scope: [Scope] = [.userHome],
		sortDescriptors: [NSSortDescriptor]? = nil,
		operationQueue: OperationQueue = OperationQueue(),
		completionBlock: @escaping ([URL]) -> Void
	) {
		let pred = "kMDItemTextContent contains[cd] '\(searchTerm)'"
		self.init(
			predicate: NSPredicate(format: pred),
			scope: scope,
			sortDescriptors: sortDescriptors,
			operationQueue: operationQueue,
			completionBlock: completionBlock
		)
	}
}

/// Simple metadata search for display name
class DisplayNameMetadataSearch: MetadataSearch {
	@inlinable convenience init(
		_ searchTerm: String,
		scope: [Scope] = [.userHome],
		sortDescriptors: [NSSortDescriptor]? = nil,
		operationQueue: OperationQueue = OperationQueue(),
		completionBlock: @escaping ([URL]) -> Void
	) {
		self.init(
			predicate: NSPredicate(format: "kMDItemDisplayName contains[cd] '%@'", searchTerm),
			scope: scope,
			sortDescriptors: sortDescriptors,
			operationQueue: operationQueue,
			completionBlock: completionBlock
		)
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

/// A simple search for file with a specified uti (eg. public.image)*
class UTIMetadataSearch: MetadataSearch {
	/// Perform a metadata search
	/// - Parameters:
	///   - utiString: The UTI to search for (eg "public.image")
	///   - scope: The scope for the search
	///   - operationQueue: The queue to perform the search on. By default, creates a new operation queue
	///   - callback: Called when the query completes. This is called on thread of the specified operation queue
	@inlinable convenience init(
		_ utiString: String,
		scope: [Scope] = [.userHome],
		sortDescriptors: [NSSortDescriptor]? = nil,
		operationQueue: OperationQueue = OperationQueue(),
		completionBlock: @escaping ([URL]) -> Void
	) {
		self.init(
			predicate: NSPredicate(format: "kMDItemContentTypeTree == %@", utiString),
			scope: scope,
			sortDescriptors: sortDescriptors,
			operationQueue: operationQueue,
			completionBlock: completionBlock
		)
	}

	/// Perform a metadata search
	/// - Parameters:
	///   - uti: The UTType to search for (eg UTType.png)
	///   - scope: The scope for the search
	///   - operationQueue: The queue to perform the search on. By default, creates a new operation queue
	///   - callback: Called when the query completes. This is called on thread of the specified operation queue
	@available(macOS 11, iOS 14, *)
	@inlinable convenience init(
		_ uti: UTType,
		scope: [Scope] = [.userHome],
		sortDescriptors: [NSSortDescriptor]? = nil,
		operationQueue: OperationQueue = OperationQueue(),
		completionBlock: @escaping ([URL]) -> Void
	) {
		self.init(
			predicate: NSPredicate(format: "kMDItemContentTypeTree == %@", uti.identifier),
			scope: scope,
			sortDescriptors: sortDescriptors,
			operationQueue: operationQueue,
			completionBlock: completionBlock
		)
	}
}
