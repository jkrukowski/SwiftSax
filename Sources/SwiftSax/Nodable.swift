//
//  Nodable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Foundation
import Clibxml2

protocol Nodable: Attributable {
    var content: UnsafeMutablePointer<xmlChar>! { get }
    var properties: UnsafeMutablePointer<_xmlAttr>! { get }
}

extension Nodable {
    var attributeNodes: [Node] {
        var result = [Node]()
        var current = properties
        while current != nil {
            if let pointer = current, let node = Node(attribute: pointer.pointee) {
                result.append(node)
                current = current?.successor()
            } else {
                current = nil
            }
        }
        return result
    }
}

extension Nodable {
    var contentString: String? {
        guard let cString = content else {
            return nil
        }
        return String(cString: cString)
    }
}

extension _xmlNode: Nodable {}
