# DSFQuickActionBar

A spotlight-inspired quick action bar for macOS.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFQuickActionBar" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/SwiftUI-2.0+-green" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a>
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

<p align="center">
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/qab_search.png?raw=true">
      <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/qab_search.png?raw=true" alt="Swift Package Manager" width="400"/></a>
   </a>
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/qab_results.png?raw=true">
      <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/qab_results.png?raw=true" alt="Swift Package Manager" width="400"/></a>
   </a>
</p>

## Why?

I've seen this in other mac applications (particularly spotlight) and it's very useful. I have a project where it needs to allow the user to quickly access a large set of actions and hey presto!

## Integration

### Swift package manager

Add `https://github.com/dagronf/DSFQuickActionBar` to your project.

## Features

* macOS AppKit Swift Support
* macOS AppKit SwiftUI Support

You can present a quick action bar in the context of a window (where it will be centered above and within the bounds of the window as is shown in the image above) or centered in the current screen (like Spotlight currently does).

| Name              | Type      | Description |
|-------------------|-----------|-------------|
| placeholderText   | `String`  | The placeholder text to display in the edit field |
| searchImage       | `NSImage` | The image to display on the left of the search edit field, or nil for no image |
| initialSearchText | `String`  (optional) | Provide an initial search string to appear when the bar displays |
| width             | `CGFloat` (optional) | Force the width of the action bar |

**NOTE:** Due to limitations of my understanding of integrating SwiftUI into macOS, the SwiftUI implementation doesn't support placing a quick action bar in front of a specific window. It (currently) only supports a global quick action bar (like Spotlight).

## Process

1. Present the quick action bar, automatically focussing on the edit field so your hands can stay on the keyboard
2. User starts typing in the search field
3. For each change to the search term -
   1. The contentSource will be asked for the identifiers that 'match' the search term (`itemsForSearchTerm`)
   2. For each item, the contentSource will be asked to provide a view which will appear in the result table for that identifier (`viewForIdentifier`)
   3. When the user either double-clicks on, or presses the return key on a selected identifier row, the contentSource will be provided with the identifier (`didSelectIdentifier`)
4. The quick action bar will automatically dismiss if
	1. The user clicks outside the quick action bar (ie. it loses focus)
	2. The user presses the escape key
	3. The user double-clicks an item in the result table
	4. The user selects a row and presses 'return'

## Implementing for AppKit

The contentSource (`DSFQuickActionBarContentSource`) provides the content and feedback for the quick action bar. The basic mechanism is similar to `NSTableViewDataSource`/`NSTableViewDelegate` in that the control will :-

1. query the contentSource for items matching a search term (itemsForSearchTerm)
2. ask the contentSource for a view to display each item (viewForIdentifier)
3. indicate that the user has pressed/clicked a selection in the results.
4. (optional) indicate to the contentSource that the quick action bar has been dismissed.

#### identifiersForSearchTerm

```swift
// Swift
func quickActionBar(_ quickActionBar: DSFQuickActionBar, identifiersForSearchTerm searchTerm: String) -> [AnyHashable]
```

Returns an array of the unique identifiers for items that match the search term. The definition of 'match' is entirely up to you - you can perform any check you want. 

#### viewForIdentifier

```swift
// Swift
func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: AnyHashable, searchTerm: String) -> NSView?
```

Return the view to be displayed in the row for the item that matches the identifier. The search term is also provided to allow the view to be customized for the search term (eg. highlighting the match in the name)

#### didSelectIdentifier

```swift
// Swift
func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectIdentifier identifier: AnyHashable)
```

Indicates the user activated an item in the result list. The 'identifier' parameter is the selected item

<details>
<summary>Swift Example</summary>

### Swift Example

A simple AppKit example using Core Image Filters as the contentSource.

```swift
class ViewController: NSViewController {
   let quickActionBar = DSFQuickActionBar()
   override func viewDidLoad() {
      super.viewDidLoad()

      // Set the content source for the quick action bar
      quickActionBar.contentSource = self
   }

   @IBAction func selectFilter(_ sender: Any) {
      // Present the quick action bar
      quickActionBar.present(placeholderText: "Search for filters…")
   }
}

extension ViewController: DSFQuickActionBarContentSource {
   func quickActionBar(_ quickActionBar: DSFQuickActionBar, identifiersForSearchTerm searchTerm: String) -> [AnyHashable] {
      return Filter.search(searchTerm)
   }

   func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: AnyHashable, searchTerm: String) -> NSView? {
      guard let filter = identifier as? Filter else { fatalError() }
      // For the demo, just return a simple text field with the filter's name
      return NSTextField(labelWithString: filter.userPresenting)
   }

   func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectIdentifier identifier: AnyHashable) {
      Swift.print("Selected identifier \(identifier as? Filter)")
   }
}

// the datasource for the Quick action bar. Each filter represents a CIFilter
struct Filter: Hashable, CustomStringConvertible {
   let name: String // The name is unique within our dataset, therefore it will be our identifier
   var userPresenting: String { return CIFilter.localizedName(forFilterName: self.name) ?? self.name }
   var description: String { name }

   // All of the available filters
   static var AllFilters: [Filter] = {
      let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
      return filterNames.map { name in Filter(name: name) }
   }()

   // Return filters matching the search term
   static func search(_ searchTerm: String) -> [Filter] {
      if searchTerm.isEmpty { return AllFilters }
      return Filter.AllFilters
         .filter { $0.userPresenting.localizedCaseInsensitiveContains(searchTerm) }
         .sorted(by: { a, b in a.userPresenting < b.userPresenting })
   }
}
```

![Screenshot for the sample data](./Art/documentation-demo.jpg)

</details>

## Implementing for SwiftUI (macOS only)

The SwiftUI implementation is a View. 

```swift
QuickActionBar<IdentifyingObject, IdentifyingObjectView>
```

Where :-

* `IdentifyingObject` is the unique identifier object
* `IdentifyingObjectView` is the type of View used to represent `IdentifyingObject` in the view

| Parameter     | Description     |
|:-----|:-----|
| location | Where to locate the quick action bar (.window, .screen) |
| visible | If true, presents the quick action bar on the screen |
| barWidth | The width of the presented bar |
| searchTerm | The search term to use, updated when the quick action bar is closed |
| selectedItem | The item selected by the user |
| placeholderText | The text to display in the quick action bar when the search term is empty |
| identifiersForSearchTerm | A block which returns the identifiers for the specified search term |
| viewForIdentifier | A block which returns the View to display for the specified identifier |

<details>
<summary>SwiftUI Example</summary>

### SwiftUI Example

A simple macOS SwiftUI example using Core Image Filters as the content.

#### SwiftUI View

```swift
struct DocoContentView: View {
   // Binding to update when the user selects a filter
   @State var selectedFilter: Filter?
   // Binding to show/hide the quick action bar
   @State var quickActionBarVisible = false

   var body: some View {
      VStack {
         Button("Show Quick Action Bar") {
            quickActionBarVisible = true
         }
         QuickActionBar<Filter, Text>(
            location: .screen,
            visible: $quickActionBarVisible,
            selectedItem: $selectedFilter,
            placeholderText: "Open Quickly...",
            identifiersForSearchTerm: { searchTerm in
               filters__.search(searchTerm)
            },
            viewForIdentifier: { filter, searchTerm in
               Text(filter.userPresenting)
            }
         )
      }
   }
}
```

#### Data

```swift
/// The unique object used as the quick action bar identifier
struct Filter: Hashable, CustomStringConvertible {
   let name: String // The name is unique within our dataset, therefore it will be our identifier
   var userPresenting: String { return CIFilter.localizedName(forFilterName: self.name) ?? self.name }
   var description: String { name }
}

class Filters {
   // If true, displays all of the filters if the search term is empty
   var showAllIfEmpty = true

   // All the filters
   var all: [Filter] = {
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

let filters__ = Filters()
```

</details>

## Screenshots

<p align="center">
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/filters-empty.png?raw=true">
      <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/filters-empty.png?raw=true" width="400"/></a>
   </a><br/>
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/filter.png?raw=true">
      <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFQuickActionBar/filter.png?raw=true" width="400"/></a>
   </a>
</p>

## Releases

### 2.0.2

* Updated demo for updated DSFAppKitBuilder

### 2.0.1

* Updated demo for updated DSFAppKitBuilder

### 2.0.0

**Note** the delegate API has changed for this version, hence moving to 2.0.0 to avoid automatic breakages

* Changed `viewForIdentifier` delegate method to also pass the current search term.
* Changed the code to use `searchTerm` (instead of `term`) consistently throughout the library

### 1.1.1

* Fixed silly runtime error for dynamic rows

### 1.1.0

* Changed the demo apps data from using 'Mountains' to using Core Image Filter definitions.

### 1.0.0

* Added initial SwiftUI support
* Changed 'delegate' to 'contentSource'

### 0.5.1

* Fixed bugs in documentation

### 0.5.0

* Initial release

## License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
