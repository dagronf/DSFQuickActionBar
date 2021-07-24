//
//  SampleData.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Foundation
import CoreImage
import DSFQuickActionBar

struct Filter {
	let id = DSFQuickActionBar.ItemIdentifier()
	let name: String

	var userPresenting: String {
		return CIFilter.localizedName(forFilterName: self.name) ?? self.name
	}

	var description: String {
		return CIFilter.localizedDescription(forFilterName: self.name) ?? ""
	}
}

let AllFilters: [Filter] = {
	let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
	return filterNames.map { name in Filter(name: name) }
}()
