//
//  SDUIView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

// MARK: - JSON-driven SwiftUI renderer

struct SDUIView: View {
    let jsonString: String
    private let root: SDUINode?
    private let onAction: ((String, SDUIActionValue) -> Void)?
    private let parseError: String?

    init(jsonString: String, onAction: ((String, SDUIActionValue) -> Void)? = nil) {
        self.jsonString = jsonString
        do {
            self.root = try SDUIParser.parse(jsonString: jsonString)
            self.parseError = nil
        } catch {
            self.root = nil
            if let le = error as? LocalizedError, let desc = le.errorDescription { self.parseError = desc } else { self.parseError = error.localizedDescription }
        }
        self.onAction = onAction
    }

    var body: some View {
        Group {
            if let error = parseError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if let root {
                SDUIRenderer.buildView(from: root, onAction: onAction)
            } else {
                Text("Invalid SDUI JSON")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let json = """
{
    "type": "vstack",
    "padding": "all:16",
    "children": [
        { "type": "text", "text": "Hello, world!", "font": "size:20,weight:semibold" },
        { "type": "hstack", "alignment": "top", "spacing": 8, "children": [
            { "type": "text", "text": "In HStack", "fontSize": 14, "fontWeight": "medium" },
            { "type": "image", "imageSystemName": "star.fill", "resizable": true, "contentMode": "fit", "width": 24, "height": 24 }
        ]},
        { "type": "zstack", "alignment": "topTrailing", "children": [
            { "type": "rectangle", "color": "#f0f0f0", "size": "200,60", "decoration": "cornerRadius:8,shadowRadius:3,shadowOffset:(x:0,y:1)" },
            { "type": "text", "text": "ZStack overlay", "padding": "all:12" }
        ]},
        { "type": "grid", "columns": 3, "spacing": 6, "children": [
            { "type": "color", "color": "red", "height": 24 },
            { "type": "color", "color": "green", "height": 24 },
            { "type": "color", "color": "blue", "height": 24 },
            { "type": "color", "color": "yellow", "height": 24 }
        ]},
        { "type": "button", "title": "Tap Me", "action": "#previewTapped", "padding": "top:8" },
        { "type": "slider", "min": 0, "max": 100, "step": 5, "value": 50, "action": "#previewSlider" },
        { "type": "toggle", "title": "Enable Feature", "isOn": true, "action": "#previewToggle" },
        { "type": "textfield", "placeholder": "Enter text", "text": "", "submitLabel": "done", "action": "#previewText" },
        { "type": "rectangle", "color": "#e0e0e0", "size": "100,100", "decoration": "cornerRadius:50,shadowColor:#00000088,shadowRadius:5,shadowOffset:(x:2,y:2)" },
        { "type": "spacer" }
    ]
}
"""
    SDUIView(jsonString: json) { name, value in
        print("Action: \(name) -> slider:\(String(describing: value.sliderValue)) toggle:\(String(describing: value.toggleValue)) text:\(String(describing: value.textChanged))")
    }
}

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
}


enum SDUIProperty: String {
    // Common
    case type // "text", "image", "button", "hstack", "vstack", "lazyhstack", "lazyvstack", "scrollview", "grid", "rectangle", "color", "spacer"
    case color // "#FF0000" or "red"
    case backgroundColor // "#FF0000" or "red" - used for background color of the element
    case padding // "left:10,right:10" or "all:10" or "vertical:10,horizontal:10"
    case margin // "left:10,right:10" or "all:10" or "vertical:10,horizontal:10" - the difference is that padding is inside the element, margin is outside (margin will still use SwiftUI padding modifier, but use it at last, after width, height and backgroundColor; while padding is used at first before width, height and backgroundColor)
    case decoration // "shadowColor:#FF0000,shadowRadius:10,shadowOffset:(x:5, y:5),cornerRadius:10,borderColor:#FF0000,borderWidth:2"
    case opacity // 0.5
    case ignoresSafeArea // "all", "horizontal", "vertical", "top", "bottom", "leading", "trailing"
    case width // 100
    case height // 100
    case size // "width:100,height:100" or "100,100" (used instead of width and height)
    case maxWidth // -1 means infinity
    case maxHeight // -1 means infinity
    case minWidth // 100
    case minHeight // 100
    case maxSize // "width:100,height:100" or "100,100" (used instead of maxWidth and maxHeight)
    case minSize // "width:100,height:100" or "100,100" (used instead of minWidth and minHeight)
    case offset // "x:10,y:10" or "10,10" - used for alignment inside ZStack
    case aspectRatio // 0.5
    case onTap // "#actionName"
    case onChange // optional alternative name for change actions
    
    // Text
    case text // "Hello, world!"
    case fontSize // 16
    case fontWeight // "ultraLight", "thin", "light", "regular", "medium", "semibold", "bold", "heavy", "black"
    case font // "size:16,weight:bold" or "16,bold"
    // case color
    case lineLimit // 0, 1, 2
    case multilineTextAlignment // "left", "center", "right"
    case minimumScaleFactor
    case strikethrough // "pattern:dash,color:#FF0000"
    case underline // "pattern:dash,color:#FF0000"
    
    // Image
    case imageName // "imageName" from Assets
    case imageURL // "https://example.com/image.png"
    case imageSystemName // "star.fill"
    case resizable // true or false
    case contentMode // "fit", "fill"
    
    // Button
    case title // "Button Title"
    case action // "#actionName"
    case label // child element
    
    // Slider
    case value // numeric value
    case min // minimum value
    case max // maximum value
    case step // optional step value
    
    // Toggle
    case isOn // boolean
    
    // TextField
    case placeholder // placeholder text
    case submitLabel // e.g., "done", "go", "search"
    
    // HStack, LazyHStack
    case alignment // "top", "center", "bottom"
    case spacing // 10
    case children // array of child elements
    
    // VStack, LazyVStack
    // case alignment // "leading", "center", "trailing"
    // case spacing // 10
    // case children // array of child elements
    
    // ZStack
    // case alignment // "top", "center", "bottom", "leading", "trailing", "topLeading", "topTrailing", "bottomLeading", "bottomTrailing"
    
    // Grid
    // case spacing // 10
    case columns // 3
    
    // ScrollView
    case axes // "horizontal", "vertical"
    case showsIndicators // true or false
    // case children // array of child elements
}

// MARK: - Internal model

fileprivate struct SDUINode {
    let type: SDUIViewType
    var props: [SDUIProperty: Any]
    var children: [SDUINode]
}

// MARK: - Parser

fileprivate enum SDUIParser {
    static func parse(jsonString: String) throws -> SDUINode {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SDUIParseError.emptyInput }
        guard let data = trimmed.data(using: .utf8) else { throw SDUIParseError.emptyInput }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            return try parseNode(obj)
        } catch let e as SDUIParseError {
            throw e
        } catch {
            throw SDUIParseError.invalidJSON(error.localizedDescription)
        }
    }

    private static func parseNode(_ obj: Any) throws -> SDUINode {
        guard let dict = obj as? [String: Any] else { throw SDUIParseError.expectedObject }
        guard let typeString = dict[SDUIProperty.type.rawValue] as? String else { throw SDUIParseError.missingType }
        guard let type = SDUIViewType(caseInsensitive: typeString) else { throw SDUIParseError.unknownType(typeString) }

        var props: [SDUIProperty: Any] = [:]
        var children: [SDUINode] = []

        for (key, value) in dict {
            if key == SDUIProperty.children.rawValue {
                if let arr = value as? [Any] {
                    children = try arr.enumerated().map { (idx, el) in
                        do { return try parseNode(el) }
                        catch { throw SDUIParseError.childError(index: idx, message: error.localizedDescription) }
                    }
                } else {
                    // tolerate single child
                    if let one = try? parseNode(value) { children = [one] }
                }
                continue
            }
            if let p = SDUIProperty(rawValue: key) {
                props[p] = value
            }
        }

        return SDUINode(type: type, props: props, children: children)
    }
}

// MARK: - Parse Errors

fileprivate enum SDUIParseError: LocalizedError {
    case emptyInput
    case invalidJSON(String)
    case expectedObject
    case missingType
    case unknownType(String)
    case childError(index: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "SDUI: JSON is empty."
        case .invalidJSON(let msg):
            return "SDUI: Invalid JSON – \(msg)"
        case .expectedObject:
            return "SDUI: Expected a JSON object at root."
        case .missingType:
            return "SDUI: Missing required 'type' property."
        case .unknownType(let t):
            return "SDUI: Unknown type '\(t)'."
        case .childError(let index, let message):
            return "SDUI: Error in child[\(index)]: \(message)"
        }
    }
}

// MARK: - Case-insensitive type matching

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

// MARK: - Renderer

fileprivate enum SDUIRenderer {
    static func buildView(from node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let base: AnyView
        switch node.type {
        case .text:
            base = anyView(makeText(node))
        case .image:
            base = anyView(makeImage(node))
        case .button:
            base = anyView(makeButton(node, onAction: onAction))
        case .slider:
            base = anyView(makeSlider(node, onAction: onAction))
        case .toggle:
            base = anyView(makeToggle(node, onAction: onAction))
        case .textfield:
            base = anyView(makeTextField(node, onAction: onAction))
        case .spacer:
            base = anyView(Spacer(minLength: nil))
        case .hstack, .lazyhstack:
            base = anyView(makeHStack(node, onAction: onAction))
        case .vstack, .lazyvstack:
            base = anyView(makeVStack(node, onAction: onAction))
        case .zstack:
            base = anyView(makeZStack(node, onAction: onAction))
        case .scrollview:
            base = anyView(makeScrollView(node, onAction: onAction))
        case .rectangle:
            base = anyView(makeRectangle(node))
        case .color:
            base = anyView(makeColor(node))
        case .grid:
            base = anyView(makeGrid(node, onAction: onAction))
        }
        // Apply general/common modifiers last, then margins (as outer padding)
        let withCore = applyCoreModifiers(to: base, using: node.props)
        let withMargin = applyMargin(to: withCore, using: node.props)
        // Attach onTap if present
        if let tap = node.props[.onTap] as? String, let name = actionName(from: tap) {
            return anyView(withMargin.onTapGesture { onAction?(name, SDUIActionValue()) })
        }
        return withMargin
    }

    // MARK: Builders

    private static func makeText(_ node: SDUINode) -> AnyView {
        let text = (node.props[.text] as? String) ?? ""
        var v: AnyView = anyView(Text(text))

        if let fontSize = double(node.props[.fontSize]) {
            if let weightStr = node.props[.fontWeight] as? String, let weight = fontWeight(weightStr) {
                v = anyView(v.font(.system(size: CGFloat(fontSize), weight: weight)))
            } else {
                v = anyView(v.font(.system(size: CGFloat(fontSize))))
            }
        } else if let fontSpec = node.props[.font] as? String {
            let (size, weight) = parseFontSpec(fontSpec)
            v = anyView(v.font(.system(size: CGFloat(size ?? 17), weight: weight ?? .regular)))
        }

        if let colorStr = node.props[.color] as? String, let color = color(from: colorStr) {
            v = anyView(v.foregroundStyle(color))
        }
        if let limit = int(node.props[.lineLimit]) {
            v = anyView(v.lineLimit(limit))
        }
        if let alignStr = node.props[.multilineTextAlignment] as? String {
            v = anyView(v.multilineTextAlignment(textAlignment(alignStr)))
        }
        if let scale = double(node.props[.minimumScaleFactor]) {
            v = anyView(v.minimumScaleFactor(scale))
        }
        if let strike = node.props[.strikethrough] as? String {
            let (active, color) = parseDecorationFlag(strike)
            v = anyView(v.strikethrough(active, color: color))
        }
        if let underline = node.props[.underline] as? String {
            let (active, color) = parseDecorationFlag(underline)
            v = anyView(v.underline(active, color: color))
        }
        return v
    }

    private static func makeImage(_ node: SDUINode) -> AnyView {
        // Priority: systemName -> asset name -> URL (if available)
        if let sys = node.props[.imageSystemName] as? String, !sys.isEmpty {
            let img = Image(systemName: sys)
            return anyView(imageView(from: img, props: node.props))
        }
        if let name = node.props[.imageName] as? String, !name.isEmpty {
            let img = Image(name)
            return anyView(imageView(from: img, props: node.props))
        }
        if let urlStr = node.props[.imageURL] as? String, let url = URL(string: urlStr) {
            let resizable = bool(node.props[.resizable]) ?? false
            let mode = (node.props[.contentMode] as? String)?.lowercased() ?? "fit"
            return anyView(AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    var v: AnyView = anyView(image)
                    if resizable { v = anyView(image.resizable()) }
                    switch mode {
                    case "fill": return anyView(v.scaledToFill())
                    default: return anyView(v.scaledToFit())
                    }
                case .failure(_):
                    return anyView(Image(systemName: "xmark.octagon").foregroundStyle(.red))
                case .empty:
                    fallthrough
                @unknown default:
                    return anyView(ProgressView())
                }
            })
        }
        // Fallback placeholder
        return anyView(Image(systemName: "photo"))
    }

    private static func imageView(from image: Image, props: [SDUIProperty: Any]) -> some View {
        var view: AnyView = anyView(image)
        if let r = bool(props[.resizable]), r {
            view = anyView(image.resizable())
        }
        if let mode = props[.contentMode] as? String {
            switch mode.lowercased() {
            case "fill": view = anyView(view.scaledToFill())
            default: view = anyView(view.scaledToFit())
            }
        }
        return view
    }

    private static func makeButton(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let title = (node.props[.title] as? String) ?? (node.props[.text] as? String) ?? "Button"
        // If a label child is provided, use it
        if let labelNode = labelChild(from: node) {
            return anyView(
                Button(action: {
                    if let act = (node.props[.action] as? String) ?? (node.props[.onTap] as? String), let name = actionName(from: act) {
                        onAction?(name, SDUIActionValue())
                    }
                }) {
                    SDUIRenderer.buildView(from: labelNode, onAction: onAction)
                }
            )
        } else {
            return anyView(
                Button(action: {
                    if let act = (node.props[.action] as? String) ?? (node.props[.onTap] as? String), let name = actionName(from: act) {
                        onAction?(name, SDUIActionValue())
                    }
                }) {
                    Text(title)
                }
            )
        }
    }

    private static func labelChild(from node: SDUINode) -> SDUINode? {
        if let label = node.props[.label] as? [String: Any], let parsed = try? SDUIParser.parse(jsonString: toJSONString(label)) {
            return parsed
        }
        // Or use first child as label if present
        return node.children.first
    }

    private static func makeHStack(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let align = horizontalAlignment(node.props[.alignment])
        let spacing = double(node.props[.spacing]).map { CGFloat($0) }
        return HStack(alignment: align, spacing: spacing) {
            ForEach(node.children.indices, id: \.self) { i in
                SDUIRenderer.buildView(from: node.children[i], onAction: onAction)
            }
        }
    }

    private static func makeVStack(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let (align, spacing) = verticalStackParams(node.props)
        return VStack(alignment: align, spacing: spacing) {
            ForEach(node.children.indices, id: \.self) { i in
                SDUIRenderer.buildView(from: node.children[i], onAction: onAction)
            }
        }
    }

    private static func makeZStack(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let align = zAlignment(node.props[.alignment])
        return ZStack(alignment: align) {
            ForEach(node.children.indices, id: \.self) { i in
                SDUIRenderer.buildView(from: node.children[i], onAction: onAction)
            }
        }
    }

    private static func makeScrollView(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let axes: Axis.Set = axes(from: node.props[.axes])
        let shows = bool(node.props[.showsIndicators]) ?? true
        // Default container inside scroll view: VStack for vertical, HStack for horizontal
        return ScrollView(axes, showsIndicators: shows) {
            if axes == .vertical {
                makeVStack(node, onAction: onAction)
            } else {
                makeHStack(node, onAction: onAction)
            }
        }
    }

    private static func makeRectangle(_ node: SDUINode) -> some View {
        let colorVal = (node.props[.color] as? String).flatMap { color(from: $0) } ?? Color.primary.opacity(0.1)
        return Rectangle().fill(colorVal)
    }

    private static func makeColor(_ node: SDUINode) -> some View {
        let colorVal = (node.props[.color] as? String).flatMap { color(from: $0) } ?? .clear
        return colorVal
    }

    private static func makeGrid(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let count = int(node.props[.columns]) ?? 2
        let spacing = double(node.props[.spacing]).map { CGFloat($0) } ?? 8
        let cols = Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(1, count))
        return LazyVGrid(columns: cols, spacing: spacing) {
            ForEach(node.children.indices, id: \.self) { i in
                SDUIRenderer.buildView(from: node.children[i], onAction: onAction)
            }
        }
    }

    private static func makeSlider(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let min = double(node.props[.min]) ?? 0
        let max = double(node.props[.max]) ?? 1
        let step = double(node.props[.step])
        let initial = double(node.props[.value]) ?? min
        let actionName = actionName(from: (node.props[.action] as? String) ?? (node.props[.onChange] as? String) ?? (node.props[.onTap] as? String) ?? "sliderChanged") ?? "sliderChanged"
        return anyView(SDUISliderView(min: min, max: max, step: step, initial: initial) { newValue in
            onAction?(actionName, SDUIActionValue(sliderValue: newValue))
        })
    }

    private static func makeToggle(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let title = (node.props[.title] as? String) ?? (node.props[.text] as? String) ?? ""
        let initial = bool(node.props[.isOn]) ?? false
        let actionName = actionName(from: (node.props[.action] as? String) ?? (node.props[.onChange] as? String) ?? (node.props[.onTap] as? String) ?? "toggleChanged") ?? "toggleChanged"
        return anyView(SDUIToggleView(title: title, initial: initial) { isOn in
            onAction?(actionName, SDUIActionValue(toggleValue: isOn))
        })
    }

    private static func makeTextField(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let placeholder = (node.props[.placeholder] as? String) ?? ""
        let initial = (node.props[.text] as? String) ?? ""
        let submit = (node.props[.submitLabel] as? String)
        let actionName = actionName(from: (node.props[.action] as? String) ?? (node.props[.onChange] as? String) ?? (node.props[.onTap] as? String) ?? "textChanged") ?? "textChanged"
        return anyView(SDUITextFieldView(placeholder: placeholder, initial: initial, submitLabel: submit) { text in
            onAction?(actionName, SDUIActionValue(textChanged: text))
        })
    }

    // MARK: Modifiers

    private static func applyCoreModifiers(to view: AnyView, using props: [SDUIProperty: Any]) -> AnyView {
        var v: AnyView = view

        if let pad = props[.padding] { v = applyPadding(v, value: pad) }

        // Frame sizing
        if let sizeStr = props[.size] as? String, let wh = parseSize(sizeStr) {
            v = anyView(v.frame(width: wh.width, height: wh.height))
        }
        let width = cgFloat(props[.width])
        let height = cgFloat(props[.height])
        var minWidth = cgFloat(props[.minWidth])
        var minHeight = cgFloat(props[.minHeight])
        var maxWidth = cgFloat(props[.maxWidth])
        var maxHeight = cgFloat(props[.maxHeight])

        if let ms = props[.minSize] as? String, let wh = parseSize(ms) { minWidth = wh.width; minHeight = wh.height }
        if let ms = props[.maxSize] as? String, let wh = parseSize(ms) { maxWidth = wh.width; maxHeight = wh.height }

        if width != nil || height != nil || minWidth != nil || minHeight != nil || maxWidth != nil || maxHeight != nil {
            v = anyView(v.frame(
                minWidth: minWidth,
                idealWidth: nil,
                maxWidth: maxWidth == CGFloat(-1) ? .infinity : maxWidth,
                minHeight: minHeight,
                idealHeight: nil,
                maxHeight: maxHeight == CGFloat(-1) ? .infinity : maxHeight,
                alignment: .center
            ))
            if let w = width { v = anyView(v.frame(width: w)) }
            if let h = height { v = anyView(v.frame(height: h)) }
        }

        if let bgStr = props[.backgroundColor] as? String, let bg = color(from: bgStr) {
            v = anyView(v.background(bg))
        }

        if let opacity = double(props[.opacity]) { v = anyView(v.opacity(opacity)) }
        if let ratio = double(props[.aspectRatio]) { v = anyView(v.aspectRatio(ratio, contentMode: .fit)) }
        if let offsetStr = props[.offset] as? String, let xy = parsePoint(offsetStr) {
            v = anyView(v.offset(x: xy.x, y: xy.y))
        }

        // Decorations
        if let deco = props[.decoration] as? String {
            v = applyDecoration(v, spec: deco)
        }

        if let ignores = props[.ignoresSafeArea] as? String {
            v = anyView(v.ignoresSafeArea(edges: safeAreaEdges(ignores)))
        }

        // Image-specific behavior handled within builders (Image/AsyncImage)

        return v
    }

    private static func applyMargin(to view: AnyView, using props: [SDUIProperty: Any]) -> AnyView {
        guard let margin = props[.margin] else { return view }
        return applyPadding(view, value: margin)
    }

    private static func applyPadding(_ view: AnyView, value: Any) -> AnyView {
        if let n = double(value) { return anyView(view.padding(CGFloat(n))) }
        if let s = value as? String {
            // Formats: "all:10" | "vertical:10,horizontal:10" | "left:10,right:10"
            var v = view
            let parts = s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.isEmpty { return v }
            var applied = false
            for part in parts {
                let kv = part.split(separator: ":").map(String.init)
                guard kv.count == 2, let val = Double(kv[1]) else { continue }
                switch kv[0].lowercased() {
                case "all": v = anyView(v.padding(CGFloat(val))); applied = true
                case "vertical": v = anyView(v.padding([.top, .bottom], CGFloat(val))); applied = true
                case "horizontal": v = anyView(v.padding([.leading, .trailing], CGFloat(val))); applied = true
                case "left", "leading": v = anyView(v.padding(.leading, CGFloat(val))); applied = true
                case "right", "trailing": v = anyView(v.padding(.trailing, CGFloat(val))); applied = true
                case "top": v = anyView(v.padding(.top, CGFloat(val))); applied = true
                case "bottom": v = anyView(v.padding(.bottom, CGFloat(val))); applied = true
                default: break
                }
            }
            return applied ? v : anyView(view)
        }
        return view
    }

    private static func applyDecoration(_ view: AnyView, spec: String) -> AnyView {
        var v = view
        // Parse keys within the spec
        let parts = spec.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var cornerRadius: Double?
        var borderColor: Color?
        var borderWidth: Double?
        var shadowColor: Color = .black.opacity(0.2)
        var shadowRadius: Double?
        var shadowX: Double = 0
        var shadowY: Double = 0
        for part in parts {
            let kv = part.split(separator: ":", maxSplits: 1).map(String.init)
            guard kv.count == 2 else { continue }
            switch kv[0].lowercased() {
            case "cornerradius": cornerRadius = Double(kv[1])
            case "bordercolor": borderColor = color(from: kv[1])
            case "borderwidth": borderWidth = Double(kv[1])
            case "shadowcolor": if let c = color(from: kv[1]) { shadowColor = c }
            case "shadowradius": shadowRadius = Double(kv[1])
            case "shadowoffset":
                if let pt = parsePoint(kv[1]) { shadowX = Double(pt.x); shadowY = Double(pt.y) }
            default: break
            }
        }

        if let r = cornerRadius { v = anyView(v.cornerRadius(CGFloat(r))) }
        if let bw = borderWidth, let bc = borderColor { v = anyView(v.overlay(RoundedRectangle(cornerRadius: CGFloat(cornerRadius ?? 0)).stroke(bc, lineWidth: CGFloat(bw)))) }
        if let sr = shadowRadius { v = anyView(v.shadow(color: shadowColor, radius: CGFloat(sr), x: CGFloat(shadowX), y: CGFloat(shadowY))) }
        return v
    }

    // MARK: Utilities

    private static func parseFontSpec(_ s: String) -> (Double?, Font.Weight?) {
        // "size:16,weight:bold" or "16,bold"
        var size: Double?
        var weight: Font.Weight?
        let parts = s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for part in parts {
            if part.contains(":") {
                let kv = part.split(separator: ":").map(String.init)
                if kv.count == 2 {
                    if kv[0].lowercased() == "size" { size = Double(kv[1]) }
                    if kv[0].lowercased() == "weight" { weight = fontWeight(kv[1]) }
                }
            } else {
                if size == nil, let n = Double(part) { size = n }
                else if weight == nil { weight = fontWeight(part) }
            }
        }
        return (size, weight)
    }

    private static func parseDecorationFlag(_ s: String) -> (Bool, Color?) {
        // Accept plain boolean-ish strings or key/value pairs e.g. "color:#FF0000"
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains(":") {
            for part in trimmed.split(separator: ",") {
                let kv = part.split(separator: ":").map(String.init)
                if kv.count == 2 && kv[0].lowercased() == "color" {
                    return (true, color(from: kv[1]))
                }
            }
            return (true, nil)
        } else {
            let active = (trimmed as NSString).boolValue
            return (active, nil)
        }
    }

    private static func parsePoint(_ s: String) -> (x: CGFloat, y: CGFloat)? {
        // formats: "x:10,y:10" or "10,10"
        let trimmed = s.trimmingCharacters(in: CharacterSet(charactersIn: "() "))
        if trimmed.contains(":") {
            var x: Double?
            var y: Double?
            for part in trimmed.split(separator: ",") {
                let kv = part.split(separator: ":").map(String.init)
                if kv.count == 2 {
                    if kv[0].lowercased().contains("x") { x = Double(kv[1]) }
                    if kv[0].lowercased().contains("y") { y = Double(kv[1]) }
                }
            }
            if let x, let y { return (CGFloat(x), CGFloat(y)) }
        } else {
            let parts = trimmed.split(separator: ",").compactMap { Double($0) }
            if parts.count == 2 { return (CGFloat(parts[0]), CGFloat(parts[1])) }
        }
        return nil
    }

    private static func parseSize(_ s: String) -> (width: CGFloat, height: CGFloat)? {
        // formats: "width:100,height:100" or "100,100"
        if s.contains(":") {
            var w: Double?
            var h: Double?
            for part in s.split(separator: ",") {
                let kv = part.split(separator: ":").map(String.init)
                if kv.count == 2 {
                    if kv[0].lowercased().contains("width") { w = Double(kv[1]) }
                    if kv[0].lowercased().contains("height") { h = Double(kv[1]) }
                }
            }
            if let w, let h { return (CGFloat(w), CGFloat(h)) }
        } else {
            let parts = s.split(separator: ",").compactMap { Double($0) }
            if parts.count == 2 { return (CGFloat(parts[0]), CGFloat(parts[1])) }
        }
        return nil
    }

    private static func axes(from value: Any?) -> Axis.Set {
        guard let s = value as? String else { return .vertical }
        switch s.lowercased() {
        case "horizontal": return .horizontal
        case "vertical": return .vertical
        default: return .vertical
        }
    }

    private static func textAlignment(_ s: String) -> TextAlignment {
        switch s.lowercased() {
        case "left", "leading": return .leading
        case "center": return .center
        case "right", "trailing": return .trailing
        default: return .leading
        }
    }

    private static func horizontalAlignment(_ value: Any?) -> VerticalAlignment {
        guard let s = value as? String else { return .center }
        switch s.lowercased() {
        case "top": return .top
        case "bottom": return .bottom
        default: return .center
        }
    }

    private static func verticalStackParams(_ props: [SDUIProperty: Any]) -> (HorizontalAlignment, CGFloat?) {
        let alignStr = (props[.alignment] as? String)?.lowercased() ?? "center"
        let align: HorizontalAlignment = {
            switch alignStr {
            case "leading", "left": return .leading
            case "trailing", "right": return .trailing
            default: return .center
            }
        }()
        let spacing = double(props[.spacing]).map { CGFloat($0) }
        return (align, spacing)
    }

    private static func zAlignment(_ value: Any?) -> Alignment {
        guard let s = (value as? String)?.lowercased() else { return .center }
        switch s {
        case "top": return .top
        case "bottom": return .bottom
        case "leading", "left": return .leading
        case "trailing", "right": return .trailing
        case "topleading": return .topLeading
        case "toptrailing": return .topTrailing
        case "bottomleading": return .bottomLeading
        case "bottomtrailing": return .bottomTrailing
        default: return .center
        }
    }

    private static func fontWeight(_ s: String) -> Font.Weight? {
        switch s.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return nil
        }
    }

    private static func color(from s: String) -> Color? {
        let lower = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // Hex: #RRGGBB or #RRGGBBAA
        if lower.hasPrefix("#") {
            let hex = String(lower.dropFirst())
            if let rgba = hexToRGBA(hex) {
                return Color(.sRGB, red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
            }
        }
        switch lower {
        case "black": return .black
        case "white": return .white
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "gray", "grey": return .gray
        case "yellow": return .yellow
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "clear": return .clear
        default: return nil
        }
    }

    private static func hexToRGBA(_ hex: String) -> (r: Double, g: Double, b: Double, a: Double)? {
        let str: String
        if hex.count == 3 { // RGB (12-bit)
            str = hex.map { "\($0)\($0)" }.joined()
        } else {
            str = hex
        }
        var val: UInt64 = 0
        guard Scanner(string: str).scanHexInt64(&val) else { return nil }
        switch str.count {
        case 6: // RRGGBB
            let r = Double((val >> 16) & 0xFF) / 255.0
            let g = Double((val >> 8) & 0xFF) / 255.0
            let b = Double(val & 0xFF) / 255.0
            return (r, g, b, 1.0)
        case 8: // RRGGBBAA
            let r = Double((val >> 24) & 0xFF) / 255.0
            let g = Double((val >> 16) & 0xFF) / 255.0
            let b = Double((val >> 8) & 0xFF) / 255.0
            let a = Double(val & 0xFF) / 255.0
            return (r, g, b, a)
        default:
            return nil
        }
    }

    private static func safeAreaEdges(_ s: String) -> Edge.Set {
        switch s.lowercased() {
        case "all": return .all
        case "horizontal": return [.leading, .trailing]
        case "vertical": return [.top, .bottom]
        case "top": return .top
        case "bottom": return .bottom
        case "leading": return .leading
        case "trailing": return .trailing
        default: return .all
        }
    }

    private static func bool(_ v: Any?) -> Bool? {
        if let b = v as? Bool { return b }
        if let s = v as? String { return (s as NSString).boolValue }
        if let n = v as? NSNumber { return n.boolValue }
        return nil
    }
    private static func double(_ v: Any?) -> Double? {
        if let d = v as? Double { return d }
        if let i = v as? Int { return Double(i) }
        if let s = v as? String { return Double(s) }
        if let n = v as? NSNumber { return n.doubleValue }
        return nil
    }
    private static func int(_ v: Any?) -> Int? {
        if let i = v as? Int { return i }
        if let s = v as? String { return Int(s) }
        if let n = v as? NSNumber { return n.intValue }
        return nil
    }
    private static func cgFloat(_ v: Any?) -> CGFloat? {
        guard let d = double(v) else { return nil }
        return CGFloat(d)
    }

    private static func toJSONString(_ dict: [String: Any]) -> String {
        (try? String(data: JSONSerialization.data(withJSONObject: dict, options: []), encoding: .utf8)) ?? "{}"
    }

    private static func actionName(from raw: String) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return nil }
        return s.hasPrefix("#") ? String(s.dropFirst()) : s
    }
}

// MARK: - Action Value

struct SDUIActionValue {
    var sliderValue: Double?
    var toggleValue: Bool?
    var textChanged: String?
    init(sliderValue: Double? = nil, toggleValue: Bool? = nil, textChanged: String? = nil) {
        self.sliderValue = sliderValue
        self.toggleValue = toggleValue
        self.textChanged = textChanged
    }
}

// MARK: - Control wrappers

fileprivate struct SDUISliderView: View {
    let min: Double
    let max: Double
    let step: Double?
    let onChange: (Double) -> Void
    @State private var value: Double

    init(min: Double, max: Double, step: Double?, initial: Double, onChange: @escaping (Double) -> Void) {
        self.min = min
        self.max = max
        self.step = step
        let clamped = Swift.max(min, Swift.min(max, initial))
        self._value = State(initialValue: clamped)
        self.onChange = onChange
    }

    var body: some View {
        Slider(value: $value, in: min...max, step: step ?? 1)
            .onChange(of: value) { onChange($0) }
    }
}

fileprivate struct SDUIToggleView: View {
    let title: String
    let onChange: (Bool) -> Void
    @State private var isOn: Bool

    init(title: String, initial: Bool, onChange: @escaping (Bool) -> Void) {
        self.title = title
        self._isOn = State(initialValue: initial)
        self.onChange = onChange
    }

    var body: some View {
        Toggle(title, isOn: $isOn)
            .onChange(of: isOn) { onChange($0) }
    }
}

fileprivate struct SDUITextFieldView: View {
    let placeholder: String
    let submit: SubmitLabel?
    let onChange: (String) -> Void
    @State private var text: String

    init(placeholder: String, initial: String, submitLabel: String?, onChange: @escaping (String) -> Void) {
        self.placeholder = placeholder
        self._text = State(initialValue: initial)
        self.submit = submitLabel.flatMap { SDUITextFieldView.mapSubmitLabel($0) }
        self.onChange = onChange
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
            .submitLabel(submit ?? .done)
            .onChange(of: text) { onChange($0) }
    }

    private static func mapSubmitLabel(_ s: String) -> SubmitLabel {
        switch s.lowercased() {
        case "done": return .done
        case "go": return .go
        case "send": return .send
        case "search": return .search
        case "join": return .join
        case "route": return .route
        case "return": return .return
        case "next": return .next
        case "continue": return .continue
        default: return .done
        }
    }
}

// MARK: - AnyView helpers

fileprivate func anyView<V: View>(_ v: V) -> AnyView { AnyView(v) }

fileprivate extension AnyView { }
