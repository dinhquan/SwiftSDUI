//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import SwiftUI

public struct SDUIView: View {
    private let root: SDUINode?
    private let onAction: ((String, SDUIActionValue) -> Void)?
    private let parseError: String?
    private let parameters: [String: Any]
    private let remoteURL: URL?
    private let customViewProvider: ((String) -> AnyView?)?

    // From JSON string
    public init(
        json: String,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customViewProvider: ((String) -> AnyView?)? = nil
    ) {
        self.parameters = parameters
        self.remoteURL = nil
        self.customViewProvider = customViewProvider
        do {
            self.root = try SDUIParser.parse(
                jsonString: json,
                params: parameters
            )
            self.parseError = nil
        } catch {
            self.root = nil
            if let le = error as? LocalizedError, let desc = le.errorDescription
            {
                self.parseError = desc
            } else {
                self.parseError = error.localizedDescription
            }
        }
        self.onAction = onAction
    }

    // Generic convenience: provider returning any View
    public init<V: View>(
        json: String,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customView: ((String) -> V?)? = nil
    ) {
        self.init(
            json: json,
            parameters: parameters,
            onAction: onAction,
            customViewProvider: { id in customView?(id).map { AnyView($0) } }
        )
    }

    // From already decoded object
    public init(
        jsonObject: Any,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customViewProvider: ((String) -> AnyView?)? = nil
    ) {
        self.parameters = parameters
        self.remoteURL = nil
        self.customViewProvider = customViewProvider
        do {
            self.root = try SDUIParser.parse(
                jsonObject: jsonObject,
                params: parameters
            )
            self.parseError = nil
        } catch {
            self.root = nil
            if let le = error as? LocalizedError, let desc = le.errorDescription
            {
                self.parseError = desc
            } else {
                self.parseError = error.localizedDescription
            }
        }
        self.onAction = onAction
    }

    public init<V: View>(
        jsonObject: Any,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customView: ((String) -> V?)? = nil
    ) {
        self.init(
            jsonObject: jsonObject,
            parameters: parameters,
            onAction: onAction,
            customViewProvider: { id in customView?(id).map { AnyView($0) } }
        )
    }

    // From JSON data
    public init(
        data: Data,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customViewProvider: ((String) -> AnyView?)? = nil
    ) {
        self.parameters = parameters
        self.remoteURL = nil
        self.customViewProvider = customViewProvider
        do {
            self.root = try SDUIParser.parse(data: data, params: parameters)
            self.parseError = nil
        } catch {
            self.root = nil
            if let le = error as? LocalizedError, let desc = le.errorDescription
            {
                self.parseError = desc
            } else {
                self.parseError = error.localizedDescription
            }
        }
        self.onAction = onAction
    }

    public init<V: View>(
        data: Data,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customView: ((String) -> V?)? = nil
    ) {
        self.init(
            data: data,
            parameters: parameters,
            onAction: onAction,
            customViewProvider: { id in customView?(id).map { AnyView($0) } }
        )
    }

    // Async init with URL
    public init(
        jsonURL: String,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customViewProvider: ((String) -> AnyView?)? = nil
    ) {
        self.parameters = parameters
        self.onAction = onAction
        self.customViewProvider = customViewProvider
        if let url = URL(string: jsonURL) {
            self.remoteURL = url
            self.root = nil
            self.parseError = nil
        } else {
            self.remoteURL = nil
            self.root = nil
            self.parseError = "SDUI: Invalid URL \(jsonURL)"
        }
    }

    public init<V: View>(
        jsonURL: String,
        parameters: [String: Any] = [:],
        onAction: ((String, SDUIActionValue) -> Void)? = nil,
        customView: ((String) -> V?)? = nil
    ) {
        self.init(
            jsonURL: jsonURL,
            parameters: parameters,
            onAction: onAction,
            customViewProvider: { id in customView?(id).map { AnyView($0) } }
        )
    }

    public var body: some View {
        Group {
            if let url = remoteURL {
                SDUIRemoteLoader(
                    url: url,
                    parameters: parameters,
                    onAction: onAction,
                    customView: customViewProvider
                )
            } else if let error = parseError {
                Text(error).font(.footnote).foregroundStyle(.red)
            } else if let root {
                SDUIRenderer.buildView(
                    from: root,
                    onAction: onAction,
                    customView: customViewProvider
                )
            } else {
                Text("Invalid SDUI JSON").font(.footnote).foregroundStyle(
                    .secondary
                )
            }
        }
    }
}
