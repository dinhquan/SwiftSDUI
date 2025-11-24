# SwiftSDUI — JSON‑Driven UI for SwiftUI

SwiftSDUI lets you describe SwiftUI screens in JSON and render them at runtime. It’s a lightweight Server‑Driven UI (SDUI) layer: ship layout and behavior from your server, keep logic in your app.

## Features
- SwiftUI rendering from JSON (containers, text, images, shapes, controls)
- Case‑insensitive `type` mapping and property schema
- Actions via `onTap`/`action` with typed payloads (`SDUIActionValue`)
- Parameter interpolation with `$name` (typed replacement or inline strings)
- Async remote JSON loading (`jsonURL:`) with loading/error UI
- Disk‑only caching for remote images (`imageURL`)
- Custom view injection with `type: "custom"` + `viewId`
- Helpful, precise parse errors for invalid JSON/schemas

## Installation
- Drop the `Source/` folder into your project, or
- Create a Swift Package and include the files from `Source/`

Import and render:
```swift
import SwiftUI

let json = """
{ "type": "text", "text": "Hello, $name", "font": "size:20,weight:semibold" }
"""

struct Demo: View {
    var body: some View {
        SDUIView(json: json,
                 parameters: ["name": "Quan Nguyen"],
                 onAction: { name, value in print(name, value) })
    }
}
```

## JSON Schema (overview)
Common properties (apply to most views):
- `padding`, `margin`, `width`, `height`, `size`, `minWidth`, `minHeight`, `maxWidth` (use `-1` for infinity), `maxHeight`
- `backgroundColor`, `color`, `opacity`, `aspectRatio`, `offset`, `ignoresSafeArea`
- `decoration`: `cornerRadius`, `borderColor`, `borderWidth`, `shadowColor`, `shadowRadius`, `shadowOffset:(x:..,y:..)`

Containers and controls:
- `vstack` | `hstack` | `zstack` | `scrollview` | `grid { columns }` | `tabview { selection }`
- `text { text, fontSize | font (e.g. "size:16,weight:bold"), fontWeight, lineLimit, multilineTextAlignment }`
- `image { imageSystemName | imageName | imageURL, resizable, contentMode:"fit|fill" }`
- `rectangle { color }`, `color { color }`, `spacer`
- `button { title | label(child), action | onTap }`
- `slider { min, max, step, value, action | onChange }`
- `toggle { title | text, isOn, action | onChange }`
- `textfield { placeholder, text, submitLabel, action | onChange }`
- `custom { viewId }` → provided by your app (see Custom Views)

All keys in `type` are case‑insensitive (e.g., `"VStack"` or `"vstack"`).

## Parameters (`$name`)
- If a string equals a single token like `$value`, it is replaced with the parameter value preserving the original type (String/Number/Bool/Array/Dict).
- If a string contains `$name` within text (e.g., `"Hello, $name"`), it is interpolated as text.

## Actions and `SDUIActionValue`
- Any node can trigger actions via `onTap:"#actionName"`.
- Controls send typed payloads:
  - Slider → `SDUIActionValue(sliderValue: Double)`
  - Toggle → `SDUIActionValue(toggleValue: Bool)`
  - TextField → `SDUIActionValue(textChanged: String)`
- Buttons (and generic taps) send `SDUIActionValue()`.

```swift
SDUIView(json: json) { name, value in
    switch name {
    case "checkout": /* navigate */
    case "sliderChanged": print(value.sliderValue ?? 0)
    default: break
    }
}
```

## Custom Views (type: "custom")
Inject your own SwiftUI view by `viewId`:
```json
{ "type": "custom", "viewId": "custom_view_1", "padding": "all:16" }
```
```swift
SDUIView(json: json, customView: { id -> some View? in
    switch id {
    case "custom_view_1": Color.red.frame(height: 100)
    default: nil
    }
})
```
You can also pass `customViewProvider: (String) -> AnyView?` if you prefer explicit `AnyView`.

## Remote JSON
```swift
SDUIView(jsonURL: "https://example.com/screen.json",
         parameters: ["user": "Alice"],
         onAction: { name, value in /* ... */ })
```
- Shows `ProgressView` while loading and a precise error message if parsing fails.

## Image Loading and Caching
- `imageURL` uses an async loader with disk‑only caching under `Library/Caches/SDUIImageCache`.
- `resizable: true` and `contentMode: "fit|fill"` are supported.

## Error Handling
- Invalid inputs throw descriptive errors shown in the UI, e.g.:
  - `SDUI: Missing required 'type' property.`
  - `SDUI: Unknown type 'vstak'.`
  - `SDUI: Error in child[2]: …`

## Extending the Schema
- Add a new case to `SDUIViewType` in `Source/SDUITypes.swift`.
- Add properties to `SDUIProperty` with a clear inline comment.
- Implement a builder in `Source/SDUIRenderer.swift` that maps your node to SwiftUI.

## Example
```json
{
  "type": "vstack",
  "padding": "all:16",
  "children": [
    { "type": "text", "text": "Hello, $name", "font": "size:20,weight:semibold" },
    { "type": "hstack", "spacing": 8, "children": [
      { "type": "text", "text": "In HStack" },
      { "type": "image", "imageSystemName": "star.fill", "resizable": true, "contentMode": "fit", "width": 24, "height": 24 }
    ]},
    { "type": "slider", "min": 0, "max": 100, "value": 50, "action": "#sliderChanged" },
    { "type": "toggle", "title": "Enable", "isOn": true, "action": "#toggleChanged" },
    { "type": "button", "title": "Checkout", "action": "#checkout" }
  ]
}
```

## Notes & Limitations
- Grid is a simple `LazyVGrid` with `columns` count (no row/column spans yet).
- `imageURL` does not currently honor HTTP cache headers; it writes raw bytes to disk by URL hash.
- JSON parsing is forgiving on children (accepts a single child or an array).

## License
This repository is provided as‑is; include appropriate license text if distributing as a package.

