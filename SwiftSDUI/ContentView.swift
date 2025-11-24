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
    { "type": "rectangle", "color": "#e0e0e0", "size": "100,100", "decoration": "cornerRadius:50,shadowColor:#00000088,shadowRadius:5,shadowOffset:(x:2,y:2)" },
    { "type": "spacer" }
]
}
"""

struct ContentView: View {
    var body: some View {
        SDUIView(jsonString: json) { name, data in
            print("Action: \(name), Data: \(data)")
        }
    }
}

#Preview {
    ContentView()
}
