//
//  Nodeable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Foundation
import Clibxml2

protocol Nodeable: Attributeable {
    var content: UnsafeMutablePointer<xmlChar>! { get }
    var properties: UnsafeMutablePointer<_xmlAttr>! { get }
}

extension Nodeable {
    var attributeNodes: [Node] {
        var result = [Node]()
        let stride = MemoryLayout<_xmlAttr>.stride
        var index = 0
        while let attributeable = properties?[index], let node = Node(attributeable: attributeable) {
            result.append(node)
            index += stride
        }
        return result
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
