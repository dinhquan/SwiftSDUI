//
//  ExampleView.swift
//  SwiftSDUI
//
//  Created by Quan on 25/11/25.
//

import SwiftUI

struct ExampleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SDUIView(
                    json: """
                        { "type": "text", "text": "Hello, $name!", "font": "size:22,weight:bold", "color": "blue" }
                        """,
                    parameters: ["name": "SwiftSDUI"]
                )

                SDUIView(
                    json: """
                        { "type": "button", "title": "Primary Action", "backgroundColor": "orange", "padding": "vertical:10,horizontal:16", "decoration": "cornerRadius:12,shadowRadius:2,shadowOffset:(x:0,y:1)" }
                        """,
                    onAction: { name, value in
                        print("Button action: \(name) -> \(value)")
                    }
                )

                SDUIView(
                    json: """
                        { "type": "image", "imageSystemName": "heart.fill", "resizable": true, "contentMode": "fit", "size": "40,40", "color": "#e63946", "decoration": "cornerRadius:12,shadowRadius:3,shadowOffset:(x:0,y:2)" }
                        """
                )

                SDUIView(
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
                )

                SDUIView(
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
                )

                SDUIView(
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
                )

                SDUIView(
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
                )

                SDUIView(
                    json: """
                        { "type": "slider", "min": 0, "max": 100, "value": 30, "step": 5, "action": "#sliderChanged" }
                        """,
                    onAction: { name, value in
                        print(
                            "Slider action: \(name) -> \(value.sliderValue ?? 0)"
                        )
                    }
                )

                SDUIView(
                    json: """
                        { "type": "toggle", "title": "Enable notifications", "isOn": true, "padding": "all:4" }
                        """,
                    onAction: { name, value in
                        print(
                            "Toggle action: \(name) -> \(value.toggleValue ?? false)"
                        )
                    }
                )

                SDUIView(
                    json: """
                        { "type": "textfield",
                          "placeholder": "Enter email",
                          "text": "",
                          "submitLabel": "go",
                          "padding": "all:8",
                          "decoration": "cornerRadius:12,borderColor:#d1d5db,borderWidth:1"
                        }
                        """,
                    onAction: { name, value in
                        print(
                            "Text action: \(name) -> \(value.textChanged ?? "")"
                        )
                    }
                )

                SDUIView(
                    json: """
                        { "type": "video",
                          "videoURL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                          "loop": true,
                          "muted": true,
                          "volumn": 0.4,
                          "videoGravity": "fill",
                          "height": 200,
                          "decoration": "cornerRadius:12,shadowRadius:4,shadowOffset:(x:0,y:2)"
                        }
                        """
                )

                SDUIView(
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
                        """,
                    customView: { viewId in
                        Text("SwiftUI source")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                )
            }
            .padding()
        }
    }
}

#Preview {
    ExampleView()
}
