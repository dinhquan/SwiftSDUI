//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI
import UIKit
import CryptoKit

final class SDUIImageCache {
    static let shared = SDUIImageCache()
    private let ioQueue = DispatchQueue(label: "sdui.image.cache.io")
    private let folderURL: URL

    private init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("SDUIImageCache", isDirectory: true)
        self.folderURL = dir
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    func image(for url: URL) -> UIImage? {
        let file = fileURL(for: url)
        if let data = try? Data(contentsOf: file), let img = UIImage(data: data) { return img }
        return nil
    }

    func store(_ imageData: Data, for url: URL) {
        let file = fileURL(for: url)
        ioQueue.async { try? imageData.write(to: file, options: [.atomic]) }
    }

    private func fileURL(for url: URL) -> URL {
        let key = Self.hash(url.absoluteString)
        return folderURL.appendingPathComponent(key).appendingPathExtension("img")
    }

    private static func hash(_ s: String) -> String {
        let data = Data(s.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}

struct SDUICachedImageView: View {
    let url: URL
    let resizable: Bool
    let contentMode: String?
    let tint: Color?
    @State private var uiImage: UIImage?
    @State private var error: String?

    var body: some View { content().task { await load() } }

    @ViewBuilder
    private func content() -> some View {
        if let uiImage {
            renderImage(uiImage)
        } else if error != nil {
            Image(systemName: "xmark.octagon").foregroundStyle(.red)
        } else {
            ProgressView()
        }
    }

    private func renderImage(_ ui: UIImage) -> AnyView {
        let base = tint == nil ? Image(uiImage: ui).renderingMode(.original) : Image(uiImage: ui).renderingMode(.template)
        var v: AnyView = resizable ? anyView(base.resizable()) : anyView(base)
        switch (contentMode ?? "fit").lowercased() { case "fill": v = anyView(v.scaledToFill()); default: v = anyView(v.scaledToFit()) }
        if let tint { v = anyView(v.foregroundStyle(tint)) }
        return v
    }

    private func load() async {
        if let cached = SDUIImageCache.shared.image(for: url) {
            await MainActor.run { self.uiImage = cached }
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            SDUIImageCache.shared.store(data, for: url)
            if let img = UIImage(data: data) { await MainActor.run { self.uiImage = img } }
            else { await MainActor.run { self.error = "Invalid image data" } }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }
}

struct SDUIRemoteLoader: View {
    let url: URL
    let parameters: [String: Any]
    let onAction: ((String, SDUIActionValue) -> Void)?
    let customView: ((String) -> AnyView?)?

    @State private var root: SDUINode?
    @State private var error: String?

    var body: some View {
        Group {
            if let error { Text(error).font(.footnote).foregroundStyle(.red) }
            else if let root { SDUIRenderer.buildView(from: root, onAction: onAction, customView: customView) }
            else { ProgressView().progressViewStyle(.circular) }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parsed = try SDUIParser.parse(data: data, params: parameters)
            await MainActor.run { self.root = parsed }
        } catch {
            await MainActor.run {
                if let le = error as? LocalizedError, let desc = le.errorDescription { self.error = desc } else { self.error = error.localizedDescription }
            }
        }
    }
}
