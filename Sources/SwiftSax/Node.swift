//
//  Node.swift
//  SwiftSax
//
//  Created by Krukowski, Jan on 2/4/20.
//

#if os(Linux)
import Clibxml2
#else
import libxml2
#endif
import Foundation

public struct Node {
    public var type: NodeType?
    public var name: String
    public var children: [Node]
    public var attributes: [String: String]
    public var data: Data?
    public var content: String? {
        String(utf8Data: data)
    }
}

extension Node {
    init(pointer: UnsafePointer<_xmlNode>) {
        self.init(
            type: pointer.nodeType(),
            name: pointer.name(),
            children: pointer.children(),
            attributes: pointer.attributes(),
            data: pointer.data()
        )
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
        guard let nodeSet = xpath.pointee.nodesetval else {
            return []
        }
        let endIndex = Int(nodeSet.pointee.nodeNr)
        let nodeTab = nodeSet.pointee.nodeTab
        var result = [Node]()
        result.reserveCapacity(endIndex)
        for index in 0 ..< endIndex {
            if let rawNode = nodeTab?[index], let node = Node(nilPointer: rawNode) {
                result.append(node)
            }
        }
        return result
    }
}
