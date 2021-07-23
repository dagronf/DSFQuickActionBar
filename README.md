# DSFQuickActionBar

A spotlight-inspired quick action bar for macOS.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFQuickActionBar" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a>
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

```swift
class QuickActions: DSFQuickActionBarContentSource {

   struct Action {
      // Unique identifier for each action
      let identifier = DSFQuickActionBar.ItemIdentifier()
      // The name of the action
      let name: String
   }

   let actions = [
      Action(name: "Format JSON"),
      Action(name: "Format XML"),
      Action(name: "Format Swift"),
      Action(name: "Prettify JSON"),
      Action(name: "Prettify XML"),
      Action(name: "Prettify Swift"),
   ]

   let quickActionBar = DSFQuickActionBar()

   func displayQuickActionBar() {
      self.quickActionBar.contentSource = self
      self.quickActionBar.presentOnMainScreen(
         placeholderText: "Quick Actions",
         width: 600
      )
   }

   // Get all the identifiers for the actions that 'match' the term
   func quickActionBar(_: DSFQuickActionBar, identifiersForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {
      return self.actions
         .filter { $0.name.localizedCaseInsensitiveContains(term) }
         .sorted(by: { a, b in a.name < b.name })
         .map { $0.identifier }
   }

   // Get the row's view for the action with the specified identifier
   func quickActionBar(_: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
      // Find the item with the specified item identifier
      guard let action = self.actions.filter({ $0.identifier == identifier }).first else {
         fatalError()
      }
      return ActionView(action)  // ActionView() is a NSView-derived class
   }

   // Perform a task with the selected action
   func quickActionBar(_: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
      guard let action = self.actions.filter({ $0.identifier == identifier }).first else {
         fatalError()
      }
      self.performAction(action) // Do something with the selected item
   }
}
```
</details>

<details>
<summary>SwiftUI Example</summary>

### SwiftUI Example

```swift
/// SwiftUI view

struct ContentView: View {

   // A quick action bar that uses MountainViewCell to display each row in the results
   let quickActionBar = DSFQuickActionBar.SwiftUI<MountainViewCell>()

   var body: some View {
      Button("Show Quick Action Bar") {
         self.quickActionBar.present(
            placeholderText: "Search Mountains",
            contentSource: MountainContentSource(selectedMountain: $selectedMountain)
         )
      }
   }
}

/// CONTENT SOURCE DEFINITION

let AllMountains: [Mountain] = [<mountain data>]

class MountainContentSource: DSFQuickActionBarSwiftUIContentSource {

   // Binding so we can pass the selected mountain back out
   @Binding var selectedMountain: Mountain?

   init(selectedMountain: Binding<Mountain?>) {
      self._selectedMountain = selectedMountain
   }

   func identifiersForSearch(_ term: String) -> [DSFQuickActionBar.ItemIdentifier] {
      if term.isEmpty { return [] }
      return AllMountains
         .filter { $0.name.localizedCaseInsensitiveContains(term) }
         .sorted(by: { a, b in a.name < b.name })
         .prefix(100)
         .map { $0.identifier }
   }

   func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier) -> RowContent? where RowContent: View {
      guard let mountain = AllMountains.filter({ $0.identifier == identifier }).first else {
         return nil
      }
      // Return a SwiftUI View that defines the row that will be displayed for the identifier
      return MountainViewCell(name: mountain.name, height: mountain.height) as? RowContent
   }


   func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
      guard let mountain = AllMountains.filter({ $0.identifier == identifier }).first else {
         return
      }
      selectedMountain = mountain
   }

   func didCancel() {
      selectedMountain = nil
   }
}

/// CONTENT ROW SWIFTUI VIEW DEFINITION

struct MountainViewCell: View {
   let name: String
   let height: Int
   var description: String {
      return "\(name) description"
   }

   var body: some View {
      HStack {
         Image("mountain").resizable()
            .frame(width: 42, height: 42)
         VStack(alignment: .leading) {
            Text(name).font(.title)
            Text(description).font(.callout).foregroundColor(.gray)
         }
         Spacer()
         Text("\(height)").font(.callout).foregroundColor(.gray)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
      }
   }
}
```

</details>

# Releases

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
