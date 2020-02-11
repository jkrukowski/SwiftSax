//
//  Node.swift
//  SwiftSax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import libxml2
import Foundation

public protocol Nodeable {
    var type: NodeType? { mutating get }
    var name: String { mutating get }
    var children: [Node] { mutating get }
    var attributes: [String: String] { mutating get }
    var content: String? { mutating get }
}

public struct Node: Nodeable {
    public private(set) lazy var type: NodeType? = pointer.nodeType()
    public private(set) lazy var name: String = pointer.name()
    public private(set) lazy var children: [Node] = pointer.children()
    public private(set) lazy var attributes: [String: String] = pointer.attributes()
    public private(set) lazy var content: String? = pointer.content()
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
