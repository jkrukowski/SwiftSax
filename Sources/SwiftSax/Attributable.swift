//
//  Attributable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Foundation
import Clibxml2

protocol Attributable {
    var type: xmlElementType { get }
    var name: UnsafePointer<xmlChar>! { get }
    var children: UnsafeMutablePointer<_xmlNode>! { get }
}

extension Attributable {
    var nodeType: NodeType? {
        NodeType(rawValue: Int(type.rawValue))
    }

    var nameString: String {
        return String(cString: name)
    }

    var childrenNodes: [Node] {
        var result = [Node]()
        var current = children
        while current != nil {
            if let pointer = current, let node = Node(node: pointer.pointee) {
                result.append(node)
                current = current?.successor()
            } else {
                current = nil
            }
        }
        return result
    }
}

extension _xmlAttr: Attributable {}
