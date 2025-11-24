//
//  SDUIView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

struct SDUIView: View {
    init(jsonString: String) {
        
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(.system(size: 16, weight: .regular))
                
            HStack(alignment: .top) {
                
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .padding()
    }
}

#Preview {
    SDUIView(jsonString: "")
}


enum SDUIProperty {
    // Common
    case type // "text", "image", "button", "view", "hstack", "vstack", "lazyhstack", "lazyvstack", "scrollview", "grid"
    case color // "#FF0000" or "red"
    case backgroundColor
    case padding // "left:10,right:10" or "all:10" or "vertical:10,horizontal:10"
    case margin // "left:10,right:10" or "all:10" or "vertical:10,horizontal:10" - the difference is that padding is inside the element, margin is outside (margin will still use SwiftUI padding modifier, but use it at last, after width, height and backgroundColor; while padding is used at first before width, height and backgroundColor)
    case decoration // "shadowColor:#FF0000,shadowRadius:10,shadowOffset:(x:5, y:5),cornerRadius:10,borderColor:#FF0000,borderWidth:2"
    case opacity
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
    case title
    case action // "#actionName"
    case label // child element
    
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
    
    // ScrollView
    case axes // "horizontal", "vertical"
    case showsIndicators // true or false
    // case children // array of child elements
}
