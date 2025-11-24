//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

struct SDUISliderView: View {
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

struct SDUIToggleView: View {
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

struct SDUITextFieldView: View {
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

struct SDUITabViewContainer: View {
    let nodes: [SDUINode]
    let onAction: ((String, SDUIActionValue) -> Void)?
    @State private var selection: Int

    init(nodes: [SDUINode], initialSelection: Int, onAction: ((String, SDUIActionValue) -> Void)?) {
        self.nodes = nodes
        self._selection = State(initialValue: max(0, min(initialSelection, max(0, nodes.count - 1))))
        self.onAction = onAction
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(nodes.indices, id: \.self) { i in
                let child = nodes[i]
                SDUIRenderer.buildView(from: child, onAction: onAction)
                    .tabItem { tabItemLabel(for: child, index: i) }
                    .tag(i)
            }
        }
    }

    private func tabItemLabel(for node: SDUINode, index: Int) -> some View {
        let title = (node.props[.title] as? String) ?? "Tab \(index + 1)"
        if let sys = node.props[.imageSystemName] as? String, !sys.isEmpty { return AnyView(Label(title, systemImage: sys)) }
        if let name = node.props[.imageName] as? String, !name.isEmpty { return AnyView(HStack { Image(name); Text(title) }) }
        return AnyView(Text(title))
    }
}

func anyView<V: View>(_ v: V) -> AnyView { AnyView(v) }
