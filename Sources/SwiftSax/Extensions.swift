//
//  Extensions.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

extension String {
    init?(nilCString: UnsafePointer<UInt8>?) {
        guard let cString = nilCString else {
            return nil
        }
        self.init(cString: cString)
    }
}

extension UnsafePointer where Pointee == _xmlNode {
    func name() -> String {
        String(cString: pointee.name)
    }

    func nodeType() -> NodeType? {
        NodeType(rawValue: Int(pointee.type.rawValue))
    }

    func attributes() -> [String: String] {
        var attributes = [String: String]()
        var attribute = pointee.properties
        while attribute != nil {
            if let key = String(nilCString: attribute?.pointee.name), let value = self.attributes(for: key) {
                attributes[key] = value
            }
            attribute = attribute?.pointee.next
        }
        return attributes
    }

    func content() -> String? {
        guard let value = xmlNodeGetContent(self) else {
            return nil
        }
        defer {
            xmlFree(value)
        }
        return String(nilCString: value)
    }

    func attributes(for name: String) -> String? {
        guard let value = xmlGetProp(self, name) else {
            return nil
        }
        defer {
            xmlFree(value)
        }
        return String(nilCString: value)
    }

    func children() -> [Node] {
        guard let children = pointee.children else {
            return []
        }
        var result = ContiguousArray<Node>()
        var current = children.pointee.next
        while let pointer = current, let node = Node(nilPointer: pointer) {
            result.append(node)
            current = current?.pointee.next
        }
        return Array(result)
    }
}
