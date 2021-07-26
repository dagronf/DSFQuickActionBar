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

## Implementing

The contentSource (`DSFQuickActionBarContentSource`/`DSFQuickActionBarSwiftUIContentSource`) provides the content and feedback for the quick action bar. The basic mechanism is similar to `NSTableViewDataSource`/`NSTableViewDelegate` in that the control will :-

1. query the contentSource for items matching a search term (itemsForSearchTerm)
2. ask the contentSource for a view to display each item (viewForIdentifier)
3. indicate that the user has pressed/clicked a selection in the results.
4. (optional) indicate to the contentSource that the quick action bar has been dismissed.

#### identifiersForSearchTerm

Returns an array of the unique identifiers for items that match the search term. The definition of 'match' is entirely up to you - you can perform any check you want

```swift
// Swift
func quickActionBar(
   _ quickActionBar: DSFQuickActionBar,
   identifiersForSearchTerm term: String
) -> [DSFQuickActionBar.ItemIdentifier]

// SwiftUI
func identifiersForSearch(_ term: String) -> [DSFQuickActionBar.ItemIdentifier]
```

#### viewForIdentifier

Return the view to be displayed in the row for the item that matches the identifier.

```swift
// Swift
func quickActionBar(
   _ quickActionBar: DSFQuickActionBar,
   viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier
) -> NSView?

// SwiftUI
func viewForIdentifier<RowContent: View>(_ identifier: DSFQuickActionBar.ItemIdentifier) -> RowContent?
```

#### didSelectIdentifier

Indicates the user activated an item in the result list. 

```swift
// Swift
func quickActionBar(
   _ quickActionBar: DSFQuickActionBar, 
   didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier
)

// SwiftUI
func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier)
```

## Examples

<details>
<summary>Swift Example</summary>

### Swift Example

A simple AppKit example using Core Image Filters as the contentSource.

```swift
class QuickActions: DSFQuickActionBarContentSource {

   /// DATA

   struct Filter {
      let identifier = DSFQuickActionBar.ItemIdentifier()
      let name: String
      var userPresenting: String { return CIFilter.localizedName(forFilterName: self.name) ?? self.name }
      var description: String { return CIFilter.localizedDescription(forFilterName: self.name) ?? "" }
   }

   let AllFilters: [Filter] = {
      let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
      return filterNames.map { name in Filter(name: name) }
   }()

   /// ACTIONS

   let quickActionBar = DSFQuickActionBar()

   func displayQuickActionBar() {
      self.quickActionBar.contentSource = self
      self.quickActionBar.presentOnMainScreen(
         placeholderText: "Quick Actions",
         width: 600
      )
   }
   
   /// CALLBACKS

   // Get all the identifiers for the actions that 'match' the term
   func quickActionBar(_: DSFQuickActionBar, identifiersForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {
      return self.actions
         .filter { $0.userPresenting.localizedCaseInsensitiveContains(term) }
         .sorted(by: { a, b in a.userPresenting < b.userPresenting })
         .map { $0.identifier }
   }

   // Get the row's view for the action with the specified identifier
   func quickActionBar(_: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
      // Find the item with the specified item identifier
      guard let filter = self.actions.filter({ $0.identifier == identifier }).first else {
         fatalError()
      }
      return FilterRowView(filter)  // FilterRowView() is a NSView-derived class
   }

   // Perform a task with the selected action
   func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
      guard let filter = self.actions.filter({ $0.identifier == identifier }).first else {
         fatalError()
      }
      self.performAction(filter) // Do something with the selected filter
   }
}
```
</details>

<details>
<summary>SwiftUI Example</summary>

### SwiftUI Example

A simple macOS SwiftUI example using Core Image Filters as the contentSource.

#### Data

```swift
struct Filter {
   let identifier = DSFQuickActionBar.ItemIdentifier()
   let name: String
   var userPresenting: String { return CIFilter.localizedName(forFilterName: self.name) ?? self.name }
   var description: String { return CIFilter.localizedDescription(forFilterName: self.name) ?? "" }
}

let AllFilters: [Filter] = {
   let filterNames = CIFilter.filterNames(inCategory: nil).sorted()
   return filterNames.map { name in Filter(name: name) }
}()
```

#### SwiftUI View

```swift
struct ContentView: View {

   // Binding to update when the user selects a filter
   @State var selectedFilter: Filter?

   // A quick action bar that uses FilterViewCell to display each row in the results
   let quickActionBar = DSFQuickActionBar.SwiftUI<FilterRowCell>()

   var body: some View {
      Button("Show Quick Action Bar") {
         self.quickActionBar.present(
            placeholderText: "Search Core Image Filters",
            contentSource: CoreImageFiltersContentSource(selectedFilter: $selectedFilter)
         )
      }
   }
}
```

#### Content Source Definition

```swift
class CoreImageFiltersContentSource: DSFQuickActionBarSwiftUIContentSource {

   @Binding var selectedFilter: Filter?

   init(selectedFilter: Binding<Filter?>) {
      self._selectedFilter = selectedFilter
   }

   func identifiersForSearch(_ term: String) -> [DSFQuickActionBar.ItemIdentifier] {
      if term.isEmpty { return [] }
      return AllFilters
         .filter { $0.userPresenting.localizedCaseInsensitiveContains(term) }
         .sorted(by: { a, b in a.userPresenting < b.userPresenting } )
         .prefix(100)
         .map { $0.id }
   }

   func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier) -> RowContent? where RowContent: View {
      guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
         return nil
      }
      return FilterViewCell(filter: filter) as? RowContent
   }

   func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
      guard let filter = AllFilters.filter({ $0.id == identifier }).first else {
         return
      }
      selectedFilter = filter
   }

   func didCancel() {
      selectedFilter = nil
   }
}
```

#### Filter Row View

```swift
struct FilterViewCell: View {
   let filter: Filter
   var body: some View {
      HStack {
         Image("filter-color").resizable()
            .frame(width: 42, height: 42)
         VStack(alignment: .leading) {
            Text(filter.userPresenting).font(.title)
            Text(filter.description).font(.callout).foregroundColor(.gray).italic()
         }
      }
   }
}
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
