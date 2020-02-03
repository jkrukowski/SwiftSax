//
//  ParserEvent.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/29/20.
//

import Foundation

public enum ParserEvent {
    case startDocument
    case endDocument
    case startElement(name: String, attributes: [String: String])
    case endElement(name: String)
    case characters(value: String)
}

extension ParserEvent: Equatable {}
extension ParserEvent: Hashable {}

extension ParserEvent {
    public func filterEnd(
        name compareName: (String) -> Bool
    ) -> Bool {
        switch self {
        case let .endElement(name: name):
            return compareName(name)
        default:
            return false
        }
    }

    public func filterStart(
        name compareName: (String) -> Bool,
        attribute compareAttributes: ([String: String]) -> Bool = { _ in true }
    ) -> Bool {
        switch self {
        case let .startElement(name: name, attributes: attributes):
            return compareName(name) && compareAttributes(attributes)
        default:
            return false
        }
    }

    public var attributes: [String: String]? {
        switch self {
        case let .startElement(_, attributes: attributes):
            return attributes
        default:
            return nil
        }
    }

    public var name: String? {
        switch self {
        case let .startElement(name: name, _),
             let .endElement(name: name):
            return name
        default:
            return nil
        }
    }

    public var value: String? {
        switch self {
        case let .characters(value: value):
            return value
        default:
            return nil
        }
    }
}

public func has(key: String, value: String) -> ([String: String]) -> Bool {
    { $0[key] == value }
}

public func has(key: String) -> ([String: String]) -> Bool {
    { $0[key] != nil }
}

public func equals(_ value: String) -> (String) -> Bool {
    { $0 == value }
}
