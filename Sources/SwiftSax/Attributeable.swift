//
//  Attributeable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

//protocol Attributeable {
//    var type: xmlElementType { get }
//    var name: UnsafePointer<xmlChar>! { get }
//    var children: UnsafeMutablePointer<_xmlNode>! { get }
//}
//
//extension Attributeable {
//
//}

extension PathParser {
    static func parse(next: Nodeable?, createNode: (_xmlNode) -> Node?) -> [Node] {
        var result = [Node]()
        var current = next?.children
        while let nodeable = current, let node = createNode(nodeable.pointee) {
            result.append(node)
            current = current?.pointee.next
        }
        return result
    }
}

extension PathParser {
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

//extension _xmlAttr: Attributeable {}
