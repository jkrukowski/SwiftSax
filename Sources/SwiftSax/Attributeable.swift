//
//  Attributeable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Foundation
import Clibxml2

protocol Attributeable {
    var type: xmlElementType { get }
    var name: UnsafePointer<xmlChar>! { get }
    var children: UnsafeMutablePointer<_xmlNode>! { get }
}

extension Attributeable {
    var nodeType: NodeType? {
        NodeType(rawValue: Int(type.rawValue))
    }

    var nameString: String {
        return String(cString: name)
    }

    var childrenNodes: [Node] {
        return Self.parse(
            children: children,
            createNode: Node.init(nodeable:)
        )
    }
}

extension Attributeable {
    static func parse<T>(children: UnsafeMutablePointer<T>!, createNode: (T) -> Node?) -> [Node] {
        var result = [Node]()
        let stride = MemoryLayout<T>.stride
        var index = 0
        while let nodeable = children?[index], let node = createNode(nodeable) {
            result.append(node)
            index += stride
        }
        return result
    }
}

extension _xmlAttr: Attributeable {}
