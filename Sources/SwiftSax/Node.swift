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
    init?(attribute: Attributable) {
        guard let type = attribute.nodeType else {
            return nil
        }
        self.type = type
        self.name = attribute.nameString
        self.content = nil
        self.children = attribute.childrenNodes
        self.attributes = []
    }

    init?(node: Nodable) {
        guard let type = node.nodeType else {
            return nil
        }
        self.type = type
        self.name = node.nameString
        self.content = node.contentString
        self.children = node.childrenNodes
        self.attributes = node.attributeNodes
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
            if let rawNode = nodeTab?[Int(index)], let node = Node(node: rawNode.pointee) {
                result.append(node)
            }
        }
        return result
    }
}
