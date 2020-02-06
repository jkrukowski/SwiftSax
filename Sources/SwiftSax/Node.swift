//
//  Node.swift
//  SwiftSax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

public struct Node {
    public lazy var type: NodeType? = pointer.nodeType()
    public lazy var name: String = pointer.name()
    public lazy var children: [Node] = pointer.children()
    public lazy var attributes: [String: String] = pointer.attributes()
    public lazy var content: String? = pointer.content()
    private let pointer: UnsafePointer<_xmlNode>
}

extension Node {
    init(pointer: UnsafePointer<_xmlNode>) {
        self.pointer = pointer
    }
}

extension Node {
    init?(nilPointer: UnsafePointer<_xmlNode>?) {
        guard let pointer = nilPointer else {
            return nil
        }
        self.init(pointer: pointer)
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
            if let rawNode = nodeTab?[Int(index)], let node = Node(nilPointer: rawNode) {
                result.append(node)
            }
        }
        return result
    }
}
