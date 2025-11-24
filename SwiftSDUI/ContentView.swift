//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

let json = """
{
"type": "vstack",
"padding": "all:16",
"children": [
    { "type": "text", "text": "Hello, world! My name is $name", "font": "size:20,weight:semibold" },
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
    { "type": "spacer" },
    { "type": "custom", "viewId": "custom_1" }
]
}
"""

struct ContentView: View {
    var body: some View {
        let parameters = ["name": "Quan Nguyen"]
        SDUIView(json: json, parameters: parameters) { name, value in
            print("Action: \(name) -> slider:\(String(describing: value.sliderValue)) toggle:\(String(describing: value.toggleValue)) text:\(String(describing: value.textChanged))")
        } customView: { viewId in
            switch viewId {
            case "custom_1":
                return Color.red
                    .frame(height: 100)
            default:
                return nil
            }
        }
    }
}

#Preview {
    ContentView()
}
