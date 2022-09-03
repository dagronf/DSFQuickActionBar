//
//  SampleData.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Foundation
import CoreImage

let filters__ = Filters()

struct Filter: Hashable, CustomStringConvertible {
	let name: String // The name is unique within our dataset, therefore it will be our identifier
	var userPresenting: String { return CIFilter.localizedName(forFilterName: self.name) ?? self.name }
	var description: String { CIFilter.localizedDescription(forFilterName: self.name) ?? self.name }
}

class Filters {
	// If true, displays all of the filters if the search term is empty
	var showAllIfEmpty = true

	// All the filters
	let all: [Filter] = {
		let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
		return filterNames.map { name in Filter(name: name) }
	}()

	// Return filters matching the search term
	func search(_ searchTerm: String) -> [Filter] {
		if searchTerm.isEmpty && showAllIfEmpty { return all }
		return all
			.filter { $0.userPresenting.localizedCaseInsensitiveContains(searchTerm) }
			.sorted(by: { a, b in a.userPresenting < b.userPresenting })
	}
}
