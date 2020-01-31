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
    case startElement(name: String, attribues: [String: String])
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
        case .endElement(name: let name):
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
        case .startElement(name: let name, attribues: let attributes):
            return compareName(name) && compareAttributes(attributes)
        default:
            return false
        }
    }

    public var attributes: [String:String]? {
        switch self {
        case .startElement(_, attribues: let attributes):
            return attributes
        default:
            return nil
        }
    }

    public var name: String? {
        switch self {
        case .startElement(name: let name, _),
             .endElement(name: let name):
            return name
        default:
            return nil
        }
    }

    public var value: String? {
        switch self {
        case .characters(value: let value):
            return value
        default:
            return nil
        }
    }
}

public func has(key: String, value: String) -> ([String: String]) -> Bool {
    return { $0[key] == value }
}

public func has(key: String) -> ([String: String]) -> Bool {
    return { $0[key] != nil  }
}

public func equals(_ value: String) -> (String) -> Bool {
    return { $0 == value }
}
