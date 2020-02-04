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
        return Self.parse(
            children: properties,
            createNode: Node.init(attributeable:)
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
