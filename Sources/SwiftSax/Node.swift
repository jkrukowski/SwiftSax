//
//  Node.swift
//  SwiftSax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Foundation
import Clibxml2

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
        self.name = attributeable.nameString
        self.content = nil
        self.children = attributeable.childrenNodes
        self.attributes = []
    }

    init?(nodeable: Nodeable) {
        guard let type = nodeable.nodeType else {
            return nil
        }
        self.type = type
        self.name = nodeable.nameString
        self.content = nodeable.contentString
        self.children = nodeable.childrenNodes
        self.attributes = nodeable.attributeNodes
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
        for index in 0..<endIndex {
            if let rawNode = nodeTab?[Int(index)], let node = Node(nodeable: rawNode.pointee) {
                result.append(node)
            }
        }
        return result
    }
}
