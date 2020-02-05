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
    public var attributes: [Node]
    public var content: String?
}

extension Node {
    init?(attributeable: Attributeable) {
        guard let type = attributeable.nodeType else {
            return nil
        }
        self.type = type
        name = attributeable.nameString
        content = nil
        children = [] //attributeable.childrenNodes
        attributes = []
    }

    init?(nodeable: Nodeable) {
        guard let type = nodeable.nodeType else {
            return nil
        }
        self.type = type
        name = nodeable.nameString
        content = nodeable.contentString
        children = nodeable.childrenNodes
        attributes = nodeable.attributeNodes
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
            if let rawNode = nodeTab?[Int(index)], let node = Node(nodeable: rawNode.pointee) {
                result.append(node)
            }
        }
        return result
    }
}
