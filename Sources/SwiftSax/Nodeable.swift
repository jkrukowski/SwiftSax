//
//  Nodeable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

protocol Nodeable: Attributeable {
    var content: UnsafeMutablePointer<xmlChar>! { get }
    var properties: UnsafeMutablePointer<_xmlAttr>! { get }
    var next: UnsafeMutablePointer<_xmlNode>! { get }
}

extension Nodeable {
    var attributeNodes: [Node] {
        PathParser.parse(
            children: properties,
            createNode: Node.init(attributeable:)
        )
    }

    var childrenNodes: [Node] {
        PathParser.parse(
            next: children.pointee,
            createNode: Node.init(nodeable:)
        )
    }
}

extension Nodeable {
    var contentString: String? {
        guard let cString = content else {
            return nil
        }
        return String(cString: cString)
    }
}

extension _xmlNode: Nodeable {}
