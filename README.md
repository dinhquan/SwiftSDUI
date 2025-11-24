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

## JSON Schema Overview
The root is a JSON object. The `type` field determines the component. `type` values are case‑insensitive (e.g., "VStack" or "vstack"), but property keys are case‑sensitive.
Common properties include `padding`, `margin`, sizing (`width`/`height`/`size`), min/max, `backgroundColor`/`color`, `opacity`, `aspectRatio`, `offset`, `ignoresSafeArea`, and `decoration` (see Components & Properties).
Primary components:
- Containers: `vstack`, `hstack`, `zstack`, `scrollview`, `grid`, `tabview`
- Leaves/Controls: `text`, `image`, `rectangle`, `color`, `spacer`, `button`, `slider`, `toggle`, `textfield`, `custom`

## Parameters (`$token`)
- Token grammar: `$` + identifier where identifier is `[A-Za-z_][A-Za-z0-9_]*` (e.g., `$name`, `$user_id`, `$count`).
- Typed replacement: if a string equals a single token (e.g., "$count"), it is replaced with the parameter value preserving its type (String/Number/Bool/Array/Dict).
- Interpolation: if a string contains tokens inside text (e.g., "Hello, $name"), they are string‑interpolated.
- Unknown tokens are left as‑is.
```json
{ "type": "text", "text": "Hello, $first_name $last_name" }
{ "type": "slider", "value": "$progress", "min": 0, "max": 100 }
{ "type": "toggle", "isOn": "$feature_enabled" }
```

## Components & Properties
All components support the common properties below unless noted. Property names are case‑sensitive; `type` is case‑insensitive.

Common
- `padding`: number or scoped string (e.g., "all:12", "horizontal:16,vertical:8", "left:8,right:8").
- `margin`: same format as padding but applied last (outer padding).
- `width`/`height`/`size`: number or "w,h" / "width:..,height:..".
- `minWidth`/`minHeight`/`maxWidth`/`maxHeight` (use `-1` for infinite max).
- `minSize`/`maxSize`: "w,h" or "width:..,height:..".
- `backgroundColor`/`color`: named color (e.g., "red") or hex `#RRGGBB`/`#RRGGBBAA`/`#RGB`.
- `opacity`: 0.0–1.0.
- `aspectRatio`: number (width/height) using `.fit` mode by default.
- `offset`: "x:10,y:10" or "10,10".
- `ignoresSafeArea`: "all" | "horizontal" | "vertical" | "top" | "bottom" | "leading" | "trailing".
- `decoration`: `cornerRadius`, `borderColor`, `borderWidth`, `shadowColor`, `shadowRadius`, `shadowOffset:(x:..,y:..)`.
- `onTap`: "#actionName" (fires `onAction`).

Text (`type: "text"`)
- Props: `text`, `fontSize`, `fontWeight`, `font`, `lineLimit`, `multilineTextAlignment`, `minimumScaleFactor`, `strikethrough`, `underline`, `color`.
```json
{ "type": "text", "text": "Title", "font": "size:20,weight:semibold" }
{ "type": "text", "text": "Body", "fontSize": 16, "lineLimit": 2, "multilineTextAlignment": "center" }
{ "type": "text", "text": "Sale", "underline": "color:#FF0000" }
```

Image (`type: "image"`)
- Source priority: `imageSystemName` → `imageName` → `imageURL`.
- Props: `resizable` (Bool), `contentMode` ("fit" | "fill"). Remote images are disk‑cached.
```json
{ "type": "image", "imageSystemName": "star.fill", "resizable": true, "contentMode": "fit", "width": 24, "height": 24 }
{ "type": "image", "imageName": "Hero" }
{ "type": "image", "imageURL": "https://…/img.png", "resizable": true }
```

Button (`type: "button"`)
- Props: `title` | `label` (child), `action` | `onTap`.
- Sends `SDUIActionValue()` when tapped.
```json
{ "type": "button", "title": "Buy", "action": "#buy" }
{ "type": "button", "label": { "type": "hstack", "children": [
  { "type": "image", "imageSystemName": "cart" },
  { "type": "text", "text": "Buy" }
]}, "action": "#buy" }
```

Slider (`type: "slider"`)
- Props: `min`, `max`, `step?`, `value`.
- Emits `sliderValue`; action name from `action | onChange | onTap` or `sliderChanged`.
```json
{ "type": "slider", "min": 0, "max": 1, "step": 0.1, "value": 0.5, "action": "#volumeChanged" }
```

Toggle (`type: "toggle"`)
- Props: `title` or `text`, `isOn`.
- Emits `toggleValue`; action name from `action | onChange | onTap` or `toggleChanged`.
```json
{ "type": "toggle", "title": "Enabled", "isOn": true, "onChange": "#featureToggle" }
```

TextField (`type: "textfield"`)
- Props: `placeholder`, initial `text`, `submitLabel` (`done|go|search|next|continue`).
- Emits `textChanged`; action name from `action | onChange | onTap` or `textChanged`.
```json
{ "type": "textfield", "placeholder": "Email", "submitLabel": "done", "action": "#emailChanged" }
```

Spacer / Rectangle / Color
- Spacer: no extra props.
- Rectangle: `color` fill; Color: literal color view.
```json
{ "type": "rectangle", "color": "#EFEFEF", "size": "200,4" }
{ "type": "color", "color": "red", "height": 24 }
{ "type": "spacer", "height": 12 }
```

Stacks (`vstack` / `hstack` / `zstack`)
- `children`: array or single object; `spacing`: number.
- Alignment: HStack `top|center|bottom`; VStack `leading|center|trailing`; ZStack `top|bottom|leading|trailing|topLeading|topTrailing|bottomLeading|bottomTrailing`.
```json
{ "type": "vstack", "spacing": 8, "children": [
  { "type": "text", "text": "Line 1" },
  { "type": "text", "text": "Line 2" }
]}
```

ScrollView (`type: "scrollview"`)
- `axes`: "horizontal" | "vertical"; `showsIndicators`: Bool. Children in `VStack` (vertical) or `HStack` (horizontal).
```json
{ "type": "scrollview", "axes": "horizontal", "children": [ … ] }
```

Grid (`type: "grid"`)
- `columns`: Int (>= 1); optional `spacing`. Renders a `LazyVGrid`.
```json
{ "type": "grid", "columns": 3, "spacing": 6, "children": [ … ] }
```

TabView (`type: "tabview"`)
- `selection`: initial selected index. Each tab label is built from `title` and optional `imageSystemName|imageName` on the child.
```json
{ "type": "tabview", "selection": 0, "children": [
  { "type": "text", "title": "First", "imageSystemName": "1.circle", "text": "First Tab" },
  { "type": "text", "title": "Second", "imageSystemName": "2.circle", "text": "Second Tab" }
]}
```

Custom (`type: "custom"`)
- `viewId`: resolve to an app‑provided SwiftUI view.
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
 - Supports `parameters` and `customView` just like local JSON.

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
