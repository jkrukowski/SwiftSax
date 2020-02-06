//
//  Node.swift
//  SwiftSax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

public struct Node {
    public var type: NodeType
    public var name: String
    public var children: [Node]
    public var attributes: [String: String]
    public var content: String?
}

extension Node {
    init?(pointer: UnsafePointer<_xmlNode>?) {
        guard let pointer = pointer, let nodeType = pointer.nodeType() else {
            return nil
        }
        type = nodeType
        name = pointer.name()
        content = pointer.content()
        children = pointer.children()
        attributes = pointer.attributes()
    }
}

extension Node {
    static func from(xpath: xmlXPathObjectPtr) -> [Node] {
        var result = [Node]()
        guard let nodeSet = xpath.pointee.nodesetval else {
            return result
        }
        let endIndex = nodeSet.pointee.nodeNr
        let nodeTab = nodeSet.pointee.nodeTab
        for index in 0 ..< endIndex {
            if let rawNode = nodeTab?[Int(index)], let node = Node(pointer: rawNode) {
                result.append(node)
            }
        }
        return result
    }
}
