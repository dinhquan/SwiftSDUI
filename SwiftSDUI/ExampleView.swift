//
//  ExampleView.swift
//  SwiftSDUI
//
//  Created by Quan on 25/11/25.
//

import SwiftUI

struct ExampleView: View {
    private let examples: [ExampleItem] = [
        ExampleItem(
            title: "Simple text with params",
            json: """
            { "type": "text", "text": "Hello, $name!", "font": "size:22,weight:bold", "color": "blue" }
            """,
            parameters: ["name": "SwiftSDUI"]
        ),
        ExampleItem(
            title: "Button with decoration",
            json: """
            { "type": "button", "title": "Primary Action", "backgroundColor": "orange", "padding": "vertical:10,horizontal:16", "decoration": "cornerRadius:12,shadowRadius:2,shadowOffset:(x:0,y:1)" }
            """
        ),
        ExampleItem(
            title: "System image tinting",
            json: """
            { "type": "image", "imageSystemName": "heart.fill", "resizable": true, "contentMode": "fit", "size": "40,40", "color": "#e63946", "decoration": "cornerRadius:12,shadowRadius:3,shadowOffset:(x:0,y:2)" }
            """
        ),
        ExampleItem(
            title: "Card-style VStack",
            json: """
            {
                "type": "vstack",
                "spacing": 8,
                "padding": "all:12",
                "backgroundColor": "#f7f7f7",
                "decoration": "cornerRadius:12,borderColor:#dddddd,borderWidth:1",
                "children": [
                    { "type": "text", "text": "Card title", "font": "size:18,weight:semibold" },
                    { "type": "text", "text": "Description text wraps here.", "fontSize": 14, "color": "#444444" }
                ]
            }
            """
        ),
        ExampleItem(
            title: "Icon + text row",
            json: """
            {
                "type": "hstack",
                "spacing": 12,
                "padding": "all:12",
                "decoration": "cornerRadius:16,borderColor:#cccccc,borderWidth:1,shadowRadius:2,shadowOffset:(x:0,y:1)",
                "children": [
                    { "type": "image", "imageSystemName": "bolt.fill", "color": "yellow", "backgroundColor": "#222222", "padding": "all:8", "decoration": "cornerRadius:12" },
                    { "type": "text", "text": "Fast performance", "font": "size:16,weight:medium" }
                ]
            }
            """
        ),
        ExampleItem(
            title: "Horizontal scroll badges",
            json: """
            {
                "type": "scrollview",
                "axes": "horizontal",
                "padding": "horizontal:4",
                "children": [
                    { "type": "hstack", "spacing": 8, "padding": "vertical:10,horizontal:12", "backgroundColor": "#eef2ff", "decoration": "cornerRadius:16", "children": [ { "type": "image", "imageSystemName": "star.fill", "color": "#4338ca" }, { "type": "text", "text": "Featured", "fontSize": 14 } ] },
                    { "type": "hstack", "spacing": 8, "padding": "vertical:10,horizontal:12", "backgroundColor": "#ecfdf3", "decoration": "cornerRadius:16", "children": [ { "type": "image", "imageSystemName": "checkmark.seal.fill", "color": "#047857" }, { "type": "text", "text": "Verified", "fontSize": 14 } ] },
                    { "type": "hstack", "spacing": 8, "padding": "vertical:10,horizontal:12", "backgroundColor": "#fef3c7", "decoration": "cornerRadius:16", "children": [ { "type": "image", "imageSystemName": "clock.fill", "color": "#92400e" }, { "type": "text", "text": "Recent", "fontSize": 14 } ] }
                ]
            }
            """
        ),
        ExampleItem(
            title: "Grid of colors",
            json: """
            { "type": "grid", "columns": 4, "spacing": 6, "children": [
                { "type": "color", "color": "#f87171", "height": 32 },
                { "type": "color", "color": "#34d399", "height": 32 },
                { "type": "color", "color": "#60a5fa", "height": 32 },
                { "type": "color", "color": "#fbbf24", "height": 32 },
                { "type": "color", "color": "#a78bfa", "height": 32 },
                { "type": "color", "color": "#f472b6", "height": 32 },
                { "type": "color", "color": "#22d3ee", "height": 32 },
                { "type": "color", "color": "#f97316", "height": 32 }
            ] }
            """
        ),
        ExampleItem(
            title: "Slider with range",
            json: """
            { "type": "slider", "min": 0, "max": 100, "value": 30, "step": 5, "action": "#sliderChanged" }
            """
        ),
        ExampleItem(
            title: "Toggle row",
            json: """
            { "type": "toggle", "title": "Enable notifications", "isOn": true, "padding": "all:4" }
            """
        ),
        ExampleItem(
            title: "Custom view injection",
            json: """
            {
                "type": "vstack",
                "spacing": 8,
                "padding": "all:12",
                "decoration": "cornerRadius:16,borderColor:#e5e7eb,borderWidth:1",
                "children": [
                    { "type": "text", "text": "Injected view below", "font": "size:16,weight:medium" },
                    { "type": "custom", "viewId": "sample_badge" }
                ]
            }
            """
        ) { id in
            guard id == "sample_badge" else { return nil }
            return AnyView(
                Text("SwiftUI source")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            )
        }
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(examples.indices, id: \.self) { idx in
                    let example = examples[idx]
                    VStack(alignment: .leading, spacing: 12) {
                        Text(example.title)
                            .font(.headline)
                        SDUIView(json: example.json, parameters: example.parameters) { name, value in
                            print("Example \(idx + 1) action: \(name) -> \(value)")
                        } customView: { viewId in
                            example.customView(viewId)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ExampleView()
}

private struct ExampleItem {
    let title: String
    let json: String
    let parameters: [String: Any]
    let customView: (String) -> AnyView?

    init(title: String, json: String, parameters: [String: Any] = [:], customView: @escaping (String) -> AnyView? = { _ in nil }) {
        self.title = title
        self.json = json
        self.parameters = parameters
        self.customView = customView
    }
}
