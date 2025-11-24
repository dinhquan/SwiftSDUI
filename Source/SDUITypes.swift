//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

enum SDUIViewType: String, CaseIterable {
    case spacer = "Spacer"
    case hstack = "HStack"
    case vstack = "VStack"
    case zstack = "ZStack"
    case lazyhstack = "LazyHStack"
    case lazyvstack = "LazyVStack"
    case scrollview = "ScrollView"
    case grid = "Grid"
    case text = "Text"
    case image = "Image"
    case button = "Button"
    case rectangle = "Rectangle"
    case color = "Color"
    case slider = "Slider"
    case toggle = "Toggle"
    case textfield = "TextField"
    case tabview = "TabView"
}

enum SDUIProperty: String {
    // Common
    case type // "text", "image", "button", "hstack", "vstack", "lazyhstack", "lazyvstack", "scrollview", "grid", "rectangle", "color", "spacer"
    case color // "#FF0000" or named color like "red"
    case backgroundColor // "#FF0000" or named color — background fill for the element
    case padding // "left:10,right:10" | "all:10" | "vertical:10,horizontal:10"
    case margin // like padding but applied last as outer padding (layout → style → effects → margin)
    case decoration // "shadowColor:#FF0000,shadowRadius:10,shadowOffset:(x:5,y:5),cornerRadius:10,borderColor:#FF0000,borderWidth:2"
    case opacity // 0.0…1.0
    case ignoresSafeArea // "all" | "horizontal" | "vertical" | "top" | "bottom" | "leading" | "trailing"
    case width // 100
    case height // 100
    case size // "width:100,height:100" or "100,100" (shortcut for width+height)
    case maxWidth // -1 means infinity
    case maxHeight // -1 means infinity
    case minWidth // 100
    case minHeight // 100
    case maxSize // "width:100,height:100" or "100,100" (shortcut for maxWidth+maxHeight)
    case minSize // "width:100,height:100" or "100,100" (shortcut for minWidth+minHeight)
    case offset // "x:10,y:10" or "10,10" — used for positioning (e.g., inside ZStack)
    case aspectRatio // 0.5
    case onTap // "#actionName"
    case onChange // Optional alternative key for change actions (slider/toggle/textfield)

    // Text
    case text // "Hello, world!"
    case fontSize // 16
    case fontWeight // "ultraLight" | "thin" | "light" | "regular" | "medium" | "semibold" | "bold" | "heavy" | "black"
    case font // "size:16,weight:bold" or "16,bold"
    // case color — use common color property
    case lineLimit // 0, 1, 2 …
    case multilineTextAlignment // "left" | "center" | "right"
    case minimumScaleFactor // e.g., 0.8
    case strikethrough // "color:#FF0000" (boolean without key also supported)
    case underline // "color:#FF0000" (boolean without key also supported)

    // Image
    case imageName // Asset name
    case imageURL // "https://example.com/image.png"
    case imageSystemName // SF Symbol, e.g., "star.fill"
    case resizable // true | false
    case contentMode // "fit" | "fill"

    // Button
    case title // "Button Title"
    case action // "#actionName"
    case label // child element (JSON object) used as custom label

    // Slider
    case value // numeric current value
    case min // minimum value
    case max // maximum value
    case step // optional step value

    // Toggle
    case isOn // boolean

    // TextField
    case placeholder // placeholder text
    case submitLabel // "done" | "go" | "search" | etc.

    // Layout containers
    case alignment // HStack: "top|center|bottom"; VStack/ZStack: "leading|center|trailing" or composites
    case spacing // 10
    case children // array of child elements

    // Grid
    case columns // number of columns, e.g., 3

    // ScrollView
    case axes // "horizontal" | "vertical"
    case showsIndicators // true | false

    // TabView
    case selection // initial selected index
}

// Node model
struct SDUINode {
    let type: SDUIViewType
    var props: [SDUIProperty: Any]
    var children: [SDUINode]
}

// Case-insensitive type lookup
extension SDUIViewType {
    init?(caseInsensitive raw: String) {
        let lower = raw.lowercased()
        if let match = Self.allCases.first(where: { $0.rawValue.lowercased() == lower }) {
            self = match
        } else {
            return nil
        }
    }
}
