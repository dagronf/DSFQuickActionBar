//
//  SampleData.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Foundation
import CoreImage
import DSFQuickActionBar

class Filter {
	// Filter name is unique for filters
	let name: String
	init(name: String) {
		self.name = name
	}

	var userPresenting: String {
		return CIFilter.localizedName(forFilterName: self.name) ?? self.name
	}

	var description: String {
		return CIFilter.localizedDescription(forFilterName: self.name) ?? ""
	}
}

extension Filter: Hashable {
	static func == (lhs: Filter, rhs: Filter) -> Bool {
		lhs.name == rhs.name
	}
	func hash(into hasher: inout Hasher) {
		 hasher.combine(name)
	}
}

let AllFilters: [Filter] = {
	let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
	return filterNames.map { name in Filter(name: name) }
}()
