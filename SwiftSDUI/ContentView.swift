//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SDUIView(json: json, parameters: ["price": "$9.99"]) { actionName, value in
            switch actionName {
            case "toggleFreeTrial":
                print("Toggle Free Trial: \(value.toggleValue!)")
            case "subscribeNow":
                print("Subscribe Now tapped")
            default: ()
            }
        }
    }
}

private let json = """
{
  "type": "zstack",
  "children": [
    {
      "type": "image",
      "imageName": "bg",
      "resizable": true,
      "ignoresSafeArea": "all"
    },
    {
      "type": "vstack",
      "padding": "all:16",
      "backgroundColor": "#ffffff55",
      "children": [
        {
          "type": "image",
          "imageSystemName": "apple.logo",
          "resizable": true,
          "contentMode": "fit",
          "size": "120,120",
          "margin": "top:50",
          "color": "#3B62E5"
        },
        {
          "type": "spacer"
        },
        {
          "type": "text",
          "text": "Unlock Premium",
          "font": "40,bold",
          "padding": "horizontal:16",
          "multilineTextAlignment": "center",
          "color": "#000",
          "margin": "bottom:30"
        },
        {
          "type": "vstack",
          "alignment": "leading",
          "children": [
            {
              "type": "hstack",
              "spacing": 16,
              "children": [
                {
                  "type": "image",
                  "imageSystemName": "nosign",
                  "resizable": true,
                  "contentMode": "fit",
                  "size": "24,24",
                  "color": "black"
                },
                {
                  "type": "text",
                  "text": "Remove ads",
                  "fontSize": 16,
                  "color": "#000"
                }
              ]
            },
            {
              "type": "hstack",
              "spacing": 16,
              "children": [
                {
                  "type": "image",
                  "imageSystemName": "infinity",
                  "resizable": true,
                  "contentMode": "fit",
                  "size": "24,24",
                  "color": "black"
                },
                {
                  "type": "text",
                  "text": "Unlimited use",
                  "fontSize": 16,
                  "color": "#000"
                }
              ]
            }
          ]
        },
        {
          "type": "hstack",
          "height": "50",
          "margin": "horizontal:16,top:50,bottom:16",
          "padding": "horizontal:20",
          "backgroundColor": "white",
          "decoration": "cornerRadius:25,borderColor:#bbb,borderWidth:1",
          "children": [
            {
              "type": "text",
              "text": "Enable Free Trial",
              "font": "size:18,weight:medium",
              "color": "#000"
            },
            {
              "type": "spacer"
            },
            {
              "type": "toggle",
              "isOn": true,
              "action": "#toggleFreeTrial"
            }
          ]
        },
        {
          "type": "text",
          "text": "$price/month",
          "font": "18,bold",
          "color": "black",
          "padding": "horizontal:16,bottom:8"
        },
        {
          "type": "button",
          "label": {
            "type": "text",
            "text": "Subscribe Now",
            "font": "size:20,weight:bold",
            "color": "white",
            "backgroundColor": "#3B62E5",
            "height": 56,
            "maxWidth": "-1",
            "margin": "horizontal:24,bottom:12",
            "decoration": "cornerRadius:28,shadowColor:#00000088,shadowRadius:3,shadowOffset:(x:0,y:2)"
          },
          "action": "#subscribeNow"
        },
        {
          "type": "text",
          "text": "By subscribing, you agree to our Terms of Service and Privacy Policy.",
          "fontSize": 14,
          "color": "#888",
          "padding": "horizontal:16",
          "margin": "bottom:20",
          "multilineTextAlignment": "center"
        }
      ]
    }
  ]
}
"""

#Preview {
    ContentView()
}
