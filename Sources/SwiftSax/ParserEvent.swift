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
