//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

enum SDUIRenderer {
    static func buildView(from node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let base: AnyView
        switch node.type {
        case .text: base = anyView(makeText(node))
        case .image: base = anyView(makeImage(node))
        case .button: base = anyView(makeButton(node, onAction: onAction))
        case .slider: base = anyView(makeSlider(node, onAction: onAction))
        case .toggle: base = anyView(makeToggle(node, onAction: onAction))
        case .textfield: base = anyView(makeTextField(node, onAction: onAction))
        case .spacer: base = anyView(Spacer(minLength: nil))
        case .hstack, .lazyhstack: base = anyView(makeHStack(node, onAction: onAction))
        case .vstack, .lazyvstack: base = anyView(makeVStack(node, onAction: onAction))
        case .zstack: base = anyView(makeZStack(node, onAction: onAction))
        case .scrollview: base = anyView(makeScrollView(node, onAction: onAction))
        case .rectangle: base = anyView(makeRectangle(node))
        case .color: base = anyView(makeColor(node))
        case .grid: base = anyView(makeGrid(node, onAction: onAction))
        case .tabview: base = anyView(makeTabView(node, onAction: onAction))
        }
        let withCore = applyCoreModifiers(to: base, using: node.props)
        let withMargin = applyMargin(to: withCore, using: node.props)
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
            } else { v = anyView(v.font(.system(size: CGFloat(fontSize)))) }
        } else if let fontSpec = node.props[.font] as? String {
            let (size, weight) = parseFontSpec(fontSpec)
            v = anyView(v.font(.system(size: CGFloat(size ?? 17), weight: weight ?? .regular)))
        }
        if let colorStr = node.props[.color] as? String, let color = color(from: colorStr) { v = anyView(v.foregroundStyle(color)) }
        if let limit = int(node.props[.lineLimit]) { v = anyView(v.lineLimit(limit)) }
        if let alignStr = node.props[.multilineTextAlignment] as? String { v = anyView(v.multilineTextAlignment(textAlignment(alignStr))) }
        if let scale = double(node.props[.minimumScaleFactor]) { v = anyView(v.minimumScaleFactor(scale)) }
        if let strike = node.props[.strikethrough] as? String { let (active, color) = parseDecorationFlag(strike); v = anyView(v.strikethrough(active, color: color)) }
        if let underline = node.props[.underline] as? String { let (active, color) = parseDecorationFlag(underline); v = anyView(v.underline(active, color: color)) }
        return v
    }

    private static func makeImage(_ node: SDUINode) -> AnyView {
        if let sys = node.props[.imageSystemName] as? String, !sys.isEmpty {
            return anyView(imageView(from: Image(systemName: sys), props: node.props))
        }
        if let name = node.props[.imageName] as? String, !name.isEmpty {
            return anyView(imageView(from: Image(name), props: node.props))
        }
        if let urlStr = node.props[.imageURL] as? String, let url = URL(string: urlStr) {
            let resizable = bool(node.props[.resizable]) ?? false
            let mode = (node.props[.contentMode] as? String)?.lowercased() ?? "fit"
            return anyView(SDUICachedImageView(url: url, resizable: resizable, contentMode: mode))
        }
        return anyView(Image(systemName: "photo"))
    }

    private static func imageView(from image: Image, props: [SDUIProperty: Any]) -> AnyView {
        var view: AnyView = anyView(image)
        if let r = bool(props[.resizable]), r { view = anyView(image.resizable()) }
        if let mode = props[.contentMode] as? String {
            switch mode.lowercased() { case "fill": view = anyView(view.scaledToFill()); default: view = anyView(view.scaledToFit()) }
        }
        return view
    }

    private static func makeButton(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let title = (node.props[.title] as? String) ?? (node.props[.text] as? String) ?? "Button"
        if let labelNode = labelChild(from: node) {
            return anyView(Button(action: {
                if let act = (node.props[.action] as? String) ?? (node.props[.onTap] as? String), let name = actionName(from: act) { onAction?(name, SDUIActionValue()) }
            }) { SDUIRenderer.buildView(from: labelNode, onAction: onAction) })
        } else {
            return anyView(Button(action: {
                if let act = (node.props[.action] as? String) ?? (node.props[.onTap] as? String), let name = actionName(from: act) { onAction?(name, SDUIActionValue()) }
            }) { Text(title) })
        }
    }

    private static func labelChild(from node: SDUINode) -> SDUINode? {
        if let label = node.props[.label] as? [String: Any], let parsed = try? SDUIParser.parse(jsonObject: label) { return parsed }
        return node.children.first
    }

    private static func makeHStack(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let align = horizontalAlignment(node.props[.alignment])
        let spacing = double(node.props[.spacing]).map { CGFloat($0) }
        return HStack(alignment: align, spacing: spacing) {
            ForEach(node.children.indices, id: \.self) { i in SDUIRenderer.buildView(from: node.children[i], onAction: onAction) }
        }
    }

    private static func makeVStack(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let (align, spacing) = verticalStackParams(node.props)
        return VStack(alignment: align, spacing: spacing) {
            ForEach(node.children.indices, id: \.self) { i in SDUIRenderer.buildView(from: node.children[i], onAction: onAction) }
        }
    }

    private static func makeZStack(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let align = zAlignment(node.props[.alignment])
        return ZStack(alignment: align) {
            ForEach(node.children.indices, id: \.self) { i in SDUIRenderer.buildView(from: node.children[i], onAction: onAction) }
        }
    }

    private static func makeScrollView(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let axes: Axis.Set = axes(from: node.props[.axes])
        let shows = bool(node.props[.showsIndicators]) ?? true
        return ScrollView(axes, showsIndicators: shows) {
            if axes == .vertical { makeVStack(node, onAction: onAction) } else { makeHStack(node, onAction: onAction) }
        }
    }

    private static func makeRectangle(_ node: SDUINode) -> some View {
        let colorVal = (node.props[.color] as? String).flatMap { color(from: $0) } ?? Color.primary.opacity(0.1)
        return Rectangle().fill(colorVal)
    }
    private static func makeColor(_ node: SDUINode) -> some View { (node.props[.color] as? String).flatMap { color(from: $0) } ?? .clear }

    private static func makeGrid(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> some View {
        let count = int(node.props[.columns]) ?? 2
        let spacing = double(node.props[.spacing]).map { CGFloat($0) } ?? 8
        let cols = Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(1, count))
        return LazyVGrid(columns: cols, spacing: spacing) {
            ForEach(node.children.indices, id: \.self) { i in SDUIRenderer.buildView(from: node.children[i], onAction: onAction) }
        }
    }

    private static func makeTabView(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let initial = int(node.props[.selection]) ?? 0
        return anyView(SDUITabViewContainer(nodes: node.children, initialSelection: initial, onAction: onAction))
    }

    private static func makeSlider(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let min = double(node.props[.min]) ?? 0
        let max = double(node.props[.max]) ?? 1
        let step = double(node.props[.step])
        let initial = double(node.props[.value]) ?? min
        let name = actionName(from: (node.props[.action] as? String) ?? (node.props[.onChange] as? String) ?? (node.props[.onTap] as? String) ?? "sliderChanged") ?? "sliderChanged"
        return anyView(SDUISliderView(min: min, max: max, step: step, initial: initial) { val in onAction?(name, SDUIActionValue(sliderValue: val)) })
    }

    private static func makeToggle(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let title = (node.props[.title] as? String) ?? (node.props[.text] as? String) ?? ""
        let initial = bool(node.props[.isOn]) ?? false
        let name = actionName(from: (node.props[.action] as? String) ?? (node.props[.onChange] as? String) ?? (node.props[.onTap] as? String) ?? "toggleChanged") ?? "toggleChanged"
        return anyView(SDUIToggleView(title: title, initial: initial) { isOn in onAction?(name, SDUIActionValue(toggleValue: isOn)) })
    }

    private static func makeTextField(_ node: SDUINode, onAction: ((String, SDUIActionValue) -> Void)? = nil) -> AnyView {
        let placeholder = (node.props[.placeholder] as? String) ?? ""
        let initial = (node.props[.text] as? String) ?? ""
        let submit = (node.props[.submitLabel] as? String)
        let name = actionName(from: (node.props[.action] as? String) ?? (node.props[.onChange] as? String) ?? (node.props[.onTap] as? String) ?? "textChanged") ?? "textChanged"
        return anyView(SDUITextFieldView(placeholder: placeholder, initial: initial, submitLabel: submit) { text in onAction?(name, SDUIActionValue(textChanged: text)) })
    }

    // MARK: Modifiers and utilities
    private static func applyCoreModifiers(to view: AnyView, using props: [SDUIProperty: Any]) -> AnyView {
        var v: AnyView = view
        if let pad = props[.padding] { v = applyPadding(v, value: pad) }
        if let sizeStr = props[.size] as? String, let wh = parseSize(sizeStr) { v = anyView(v.frame(width: wh.width, height: wh.height)) }
        let width = cgFloat(props[.width]); let height = cgFloat(props[.height])
        var minWidth = cgFloat(props[.minWidth]); var minHeight = cgFloat(props[.minHeight])
        var maxWidth = cgFloat(props[.maxWidth]); var maxHeight = cgFloat(props[.maxHeight])
        if let ms = props[.minSize] as? String, let wh = parseSize(ms) { minWidth = wh.width; minHeight = wh.height }
        if let ms = props[.maxSize] as? String, let wh = parseSize(ms) { maxWidth = wh.width; maxHeight = wh.height }
        if width != nil || height != nil || minWidth != nil || minHeight != nil || maxWidth != nil || maxHeight != nil {
            v = anyView(v.frame(minWidth: minWidth, idealWidth: nil, maxWidth: maxWidth == CGFloat(-1) ? .infinity : maxWidth, minHeight: minHeight, idealHeight: nil, maxHeight: maxHeight == CGFloat(-1) ? .infinity : maxHeight))
            if let w = width { v = anyView(v.frame(width: w)) }
            if let h = height { v = anyView(v.frame(height: h)) }
        }
        if let bgStr = props[.backgroundColor] as? String, let bg = color(from: bgStr) { v = anyView(v.background(bg)) }
        if let opacity = double(props[.opacity]) { v = anyView(v.opacity(opacity)) }
        if let ratio = double(props[.aspectRatio]) { v = anyView(v.aspectRatio(ratio, contentMode: .fit)) }
        if let offsetStr = props[.offset] as? String, let xy = parsePoint(offsetStr) { v = anyView(v.offset(x: xy.x, y: xy.y)) }
        if let deco = props[.decoration] as? String { v = applyDecoration(v, spec: deco) }
        if let ignores = props[.ignoresSafeArea] as? String { v = anyView(v.ignoresSafeArea(edges: safeAreaEdges(ignores))) }
        return v
    }
    private static func applyMargin(to view: AnyView, using props: [SDUIProperty: Any]) -> AnyView { guard let margin = props[.margin] else { return view }; return applyPadding(view, value: margin) }
    private static func applyPadding(_ view: AnyView, value: Any) -> AnyView {
        if let n = double(value) { return anyView(view.padding(CGFloat(n))) }
        if let s = value as? String {
            var v = view; let parts = s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }; var applied = false
            for part in parts {
                let kv = part.split(separator: ":").map(String.init); guard kv.count == 2, let val = Double(kv[1]) else { continue }
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
        let parts = spec.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var cornerRadius: Double?; var borderColor: Color?; var borderWidth: Double?
        var shadowColor: Color = .black.opacity(0.2); var shadowRadius: Double?; var shadowX: Double = 0; var shadowY: Double = 0
        for part in parts {
            let kv = part.split(separator: ":", maxSplits: 1).map(String.init); guard kv.count == 2 else { continue }
            switch kv[0].lowercased() {
            case "cornerradius": cornerRadius = Double(kv[1])
            case "bordercolor": borderColor = color(from: kv[1])
            case "borderwidth": borderWidth = Double(kv[1])
            case "shadowcolor": if let c = color(from: kv[1]) { shadowColor = c }
            case "shadowradius": shadowRadius = Double(kv[1])
            case "shadowoffset": if let pt = parsePoint(kv[1]) { shadowX = Double(pt.x); shadowY = Double(pt.y) }
            default: break
            }
        }
        if let r = cornerRadius { v = anyView(v.cornerRadius(CGFloat(r))) }
        if let bw = borderWidth, let bc = borderColor { v = anyView(v.overlay(RoundedRectangle(cornerRadius: CGFloat(cornerRadius ?? 0)).stroke(bc, lineWidth: CGFloat(bw)))) }
        if let sr = shadowRadius { v = anyView(v.shadow(color: shadowColor, radius: CGFloat(sr), x: CGFloat(shadowX), y: CGFloat(shadowY))) }
        return v
    }

    // Helpers
    private static func parseFontSpec(_ s: String) -> (Double?, Font.Weight?) {
        var size: Double?; var weight: Font.Weight?; let parts = s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for part in parts {
            if part.contains(":") { let kv = part.split(separator: ":").map(String.init); if kv.count == 2 { if kv[0].lowercased() == "size" { size = Double(kv[1]) }; if kv[0].lowercased() == "weight" { weight = fontWeight(kv[1]) } } }
            else { if size == nil, let n = Double(part) { size = n } else if weight == nil { weight = fontWeight(part) } }
        }
        return (size, weight)
    }
    private static func parseDecorationFlag(_ s: String) -> (Bool, Color?) {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains(":") { for part in trimmed.split(separator: ",") { let kv = part.split(separator: ":").map(String.init); if kv.count == 2 && kv[0].lowercased() == "color" { return (true, color(from: kv[1])) } }; return (true, nil) }
        let active = (trimmed as NSString).boolValue; return (active, nil)
    }
    private static func parsePoint(_ s: String) -> (x: CGFloat, y: CGFloat)? {
        let trimmed = s.trimmingCharacters(in: CharacterSet(charactersIn: "() "))
        if trimmed.contains(":") { var x: Double?; var y: Double?; for part in trimmed.split(separator: ",") { let kv = part.split(separator: ":").map(String.init); if kv.count == 2 { if kv[0].lowercased().contains("x") { x = Double(kv[1]) }; if kv[0].lowercased().contains("y") { y = Double(kv[1]) } } }; if let x, let y { return (CGFloat(x), CGFloat(y)) } }
        else { let parts = trimmed.split(separator: ",").compactMap { Double($0) }; if parts.count == 2 { return (CGFloat(parts[0]), CGFloat(parts[1])) } }
        return nil
    }
    private static func parseSize(_ s: String) -> (width: CGFloat, height: CGFloat)? {
        if s.contains(":") { var w: Double?; var h: Double?; for part in s.split(separator: ",") { let kv = part.split(separator: ":").map(String.init); if kv.count == 2 { if kv[0].lowercased().contains("width") { w = Double(kv[1]) }; if kv[0].lowercased().contains("height") { h = Double(kv[1]) } } }; if let w, let h { return (CGFloat(w), CGFloat(h)) } }
        else { let parts = s.split(separator: ",").compactMap { Double($0) }; if parts.count == 2 { return (CGFloat(parts[0]), CGFloat(parts[1])) } }
        return nil
    }
    private static func axes(from value: Any?) -> Axis.Set { guard let s = value as? String else { return .vertical }; return s.lowercased() == "horizontal" ? .horizontal : .vertical }
    private static func textAlignment(_ s: String) -> TextAlignment { switch s.lowercased() { case "left", "leading": return .leading; case "center": return .center; case "right", "trailing": return .trailing; default: return .leading } }
    private static func horizontalAlignment(_ value: Any?) -> VerticalAlignment { guard let s = value as? String else { return .center }; switch s.lowercased() { case "top": return .top; case "bottom": return .bottom; default: return .center } }
    private static func verticalStackParams(_ props: [SDUIProperty: Any]) -> (HorizontalAlignment, CGFloat?) {
        let alignStr = (props[.alignment] as? String)?.lowercased() ?? "center"
        let align: HorizontalAlignment = { switch alignStr { case "leading", "left": return .leading; case "trailing", "right": return .trailing; default: return .center } }()
        let spacing = double(props[.spacing]).map { CGFloat($0) }
        return (align, spacing)
    }
    private static func zAlignment(_ value: Any?) -> Alignment {
        guard let s = (value as? String)?.lowercased() else { return .center }
        switch s { case "top": return .top; case "bottom": return .bottom; case "leading", "left": return .leading; case "trailing", "right": return .trailing; case "topleading": return .topLeading; case "toptrailing": return .topTrailing; case "bottomleading": return .bottomLeading; case "bottomtrailing": return .bottomTrailing; default: return .center }
    }
    private static func fontWeight(_ s: String) -> Font.Weight? {
        switch s.lowercased() { case "ultralight": return .ultraLight; case "thin": return .thin; case "light": return .light; case "regular": return .regular; case "medium": return .medium; case "semibold": return .semibold; case "bold": return .bold; case "heavy": return .heavy; case "black": return .black; default: return nil }
    }
    private static func color(from s: String) -> Color? {
        let lower = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if lower.hasPrefix("#"), let rgba = hexToRGBA(String(lower.dropFirst())) { return Color(.sRGB, red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a) }
        switch lower { case "black": return .black; case "white": return .white; case "red": return .red; case "green": return .green; case "blue": return .blue; case "gray", "grey": return .gray; case "yellow": return .yellow; case "orange": return .orange; case "pink": return .pink; case "purple": return .purple; case "clear": return .clear; default: return nil }
    }
    private static func hexToRGBA(_ hex: String) -> (r: Double, g: Double, b: Double, a: Double)? {
        let str = hex.count == 3 ? hex.map { "\($0)\($0)" }.joined() : hex
        var val: UInt64 = 0; guard Scanner(string: str).scanHexInt64(&val) else { return nil }
        switch str.count {
        case 6: return (Double((val >> 16) & 0xFF)/255.0, Double((val >> 8) & 0xFF)/255.0, Double(val & 0xFF)/255.0, 1.0)
        case 8: return (Double((val >> 24) & 0xFF)/255.0, Double((val >> 16) & 0xFF)/255.0, Double((val >> 8) & 0xFF)/255.0, Double(val & 0xFF)/255.0)
        default: return nil
        }
    }
    private static func safeAreaEdges(_ s: String) -> Edge.Set { switch s.lowercased() { case "all": return .all; case "horizontal": return [.leading, .trailing]; case "vertical": return [.top, .bottom]; case "top": return .top; case "bottom": return .bottom; case "leading": return .leading; case "trailing": return .trailing; default: return .all } }
    static func bool(_ v: Any?) -> Bool? { if let b = v as? Bool { return b }; if let s = v as? String { return (s as NSString).boolValue }; if let n = v as? NSNumber { return n.boolValue }; return nil }
    static func double(_ v: Any?) -> Double? { if let d = v as? Double { return d }; if let i = v as? Int { return Double(i) }; if let s = v as? String { return Double(s) }; if let n = v as? NSNumber { return n.doubleValue }; return nil }
    static func int(_ v: Any?) -> Int? { if let i = v as? Int { return i }; if let s = v as? String { return Int(s) }; if let n = v as? NSNumber { return n.intValue }; return nil }
    static func cgFloat(_ v: Any?) -> CGFloat? { guard let d = double(v) else { return nil }; return CGFloat(d) }
    static func toJSONString(_ dict: [String: Any]) -> String { (try? String(data: JSONSerialization.data(withJSONObject: dict, options: []), encoding: .utf8)) ?? "{}" }
    static func actionName(from raw: String) -> String? { let s = raw.trimmingCharacters(in: .whitespacesAndNewlines); return s.isEmpty ? nil : (s.hasPrefix("#") ? String(s.dropFirst()) : s) }
}

