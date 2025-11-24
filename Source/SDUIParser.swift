//
//  ContentView.swift
//  SwiftSDUI
//
//  Created by Quan on 24/11/25.
//

import Foundation

enum SDUIParseError: LocalizedError {
    case emptyInput
    case invalidJSON(String)
    case expectedObject
    case missingType
    case unknownType(String)
    case childError(index: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .emptyInput: return "SDUI: JSON is empty."
        case .invalidJSON(let msg): return "SDUI: Invalid JSON – \(msg)"
        case .expectedObject: return "SDUI: Expected a JSON object at root."
        case .missingType: return "SDUI: Missing required 'type' property."
        case .unknownType(let t): return "SDUI: Unknown type '\(t)'."
        case .childError(let i, let m): return "SDUI: Error in child[\(i)]: \(m)"
        }
    }
}

enum SDUIParser {
    static func parse(jsonString: String, params: [String: Any] = [:]) throws -> SDUINode {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SDUIParseError.emptyInput }
        guard let data = trimmed.data(using: .utf8) else { throw SDUIParseError.emptyInput }
        return try parse(data: data, params: params)
    }

    static func parse(jsonObject: Any, params: [String: Any] = [:]) throws -> SDUINode {
        let resolved = resolveParams(in: jsonObject, with: params)
        return try parseNode(resolved)
    }

    static func parse(data: Data, params: [String: Any] = [:]) throws -> SDUINode {
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let resolved = resolveParams(in: obj, with: params)
            return try parseNode(resolved)
        } catch let e as SDUIParseError {
            throw e
        } catch {
            throw SDUIParseError.invalidJSON(error.localizedDescription)
        }
    }

    // MARK: - Param resolution
    static func resolveParams(in obj: Any, with params: [String: Any]) -> Any {
        if let dict = obj as? [String: Any] {
            var out: [String: Any] = [:]
            for (k, v) in dict { out[k] = resolveParams(in: v, with: params) }
            return out
        } else if let arr = obj as? [Any] {
            return arr.map { resolveParams(in: $0, with: params) }
        } else if let s = obj as? String {
            return resolveString(s, with: params)
        } else {
            return obj
        }
    }

    static func resolveString(_ s: String, with params: [String: Any]) -> Any {
        if let name = singleTokenName(s), let val = params[name] { return val }
        var result = ""
        var i = s.startIndex
        while i < s.endIndex {
            let ch = s[i]
            if ch == "$" {
                let start = s.index(after: i)
                var j = start
                if j < s.endIndex, isNameStartChar(s[j]) {
                    j = s.index(after: j)
                    while j < s.endIndex, isNameChar(s[j]) { j = s.index(after: j) }
                    let name = String(s[start..<j])
                    if let val = params[name] {
                        if let vs = val as? String { result.append(vs) }
                        else { result.append(String(describing: val)) }
                        i = j; continue
                    } else {
                        result.append("$"); result.append(name)
                        i = j; continue
                    }
                } else {
                    result.append("$"); i = start; continue
                }
            }
            result.append(ch); i = s.index(after: i)
        }
        return result
    }

    static func singleTokenName(_ s: String) -> String? {
        guard s.first == "$", s.count >= 2 else { return nil }
        let start = s.index(after: s.startIndex)
        guard isNameStartChar(s[start]) else { return nil }
        var j = s.index(after: start)
        while j < s.endIndex, isNameChar(s[j]) { j = s.index(after: j) }
        return j == s.endIndex ? String(s[start..<j]) : nil
    }

    static func isNameStartChar(_ c: Character) -> Bool { c.isLetter || c == "_" }
    static func isNameChar(_ c: Character) -> Bool { c.isLetter || c.isNumber || c == "_" }

    // MARK: - Node parsing
    static func parseNode(_ obj: Any) throws -> SDUINode {
        guard let dict = obj as? [String: Any] else { throw SDUIParseError.expectedObject }
        guard let typeString = dict[SDUIProperty.type.rawValue] as? String else { throw SDUIParseError.missingType }
        guard let type = SDUIViewType(caseInsensitive: typeString) else { throw SDUIParseError.unknownType(typeString) }

        var props: [SDUIProperty: Any] = [:]
        var children: [SDUINode] = []

        for (key, value) in dict {
            if key == SDUIProperty.children.rawValue {
                if let arr = value as? [Any] {
                    children = try arr.enumerated().map { (idx, el) in
                        do { return try parseNode(el) }
                        catch { throw SDUIParseError.childError(index: idx, message: error.localizedDescription) }
                    }
                } else if let one = try? parseNode(value) {
                    children = [one]
                }
                continue
            }
            if let p = SDUIProperty(rawValue: key) { props[p] = value }
        }

        return SDUINode(type: type, props: props, children: children)
    }
}

