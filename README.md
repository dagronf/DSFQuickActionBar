# DSFQuickActionBar

A spotlight-inspired quick action bar for macOS

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFQuickActionBar" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a>
</p>


## Why?

I wanted to.

## Features

You can present a quick action bar in the context of a window (where it will be centered above and within the bounds of the window) or centered in the current screen (like Spotlight currently does)

| Name | Type | Description |
|------|--------|-------------|
| placeholderText   | `String` | The placeholder text to display in the edit field |
| searchImage       | `NSImage` | The image to display on the left of the search edit field, or nil for no image |
| width             | `CGFloat` (optional) | Force the width of the action bar |
| initialSearchText | `String` (optional) | Provide an initial search string to appear when the bar displays |


### Delegate

The delegate provides the content for the quick action bar.

#### itemsForSearchTerm

```swift
func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier]
```

Returns an array of the unique identifiers for items that match the search term. The definition of 'match' is entirely up to you - you can perform any check you want

#### viewForIdentifier

```swift
func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
```

Returns the view to be displayed in the row for the item that match the identifier

#### didSelectIdentifier

```swift
func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier)
```

Notifies the delegate that the user activated an item in the result list. 


## Example

```swift
let quickActionBar = DSFQuickActionBar()

func doSomething() {
   quickActionBar.delegate = self
   quickActionBar.presentOnMainScreen(
      placeholderText: "Quick Actions",
      width: 600
   )
}

struct Action {
   let identifier = UUID()
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

// Get all the identifiers for the actions that 'match' the term
func quickActionBar(_ quickActionBar: DSFQuickActionBar, identifiersForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {
   return self.actions
      .filter { $0.name.localizedCaseInsensitiveContains(term) }
      .sorted(by: { a, b in a.name < b.name })
      .map { $0.identifier }
}

// Get the row's view for the action with the specified identifier
func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {
   // Find the item with the specified item identifier
   guard let action = self.actions.filter({ $0.identifier == identifier }).first else {
      fatalError()
   }
   return ActionView(action)
}

// Perform a task with the selected action
func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectIdentifier identifier: DSFQuickActionBar.ItemIdentifier) {
   guard let action = self.actions.filter({ $0.identifier == identifier }).first else {
      fatalError()
   }
   self.performAction(action)  // Do something with the selected item
}

```

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
