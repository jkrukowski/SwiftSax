//
//  Nodeable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

protocol Nodeable {
    var type: xmlElementType { get }
    var name: UnsafePointer<xmlChar>! { get }
    var children: UnsafeMutablePointer<_xmlNode>! { get }
    var content: UnsafeMutablePointer<xmlChar>! { get }
    var properties: UnsafeMutablePointer<_xmlAttr>! { get }
    var next: UnsafeMutablePointer<_xmlNode>! { get }
}

func parseString<T>(from ptr: UnsafePointer<T>?) -> String? {
    if let ptr = ptr {
        return String(validatingUTF8: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
    }
    return nil

}

extension _xmlNode {
    var nodeType: NodeType? {
        NodeType(rawValue: Int(type.rawValue))
    }

    var nameString: String {
        String(cString: name)
    }
    
    func attributes(for pointer: UnsafePointer<_xmlNode>) -> [String:String] {
        var attributes = [String: String]()
        var attribute = properties
        while attribute != nil {
            if let key = parseString(from: attribute?.pointee.name), let value = self.attributes(for: key, with: pointer) {
                attributes[key] = value
            }
            attribute = attribute?.pointee.next
        }
        return attributes
    }

    func content(for pointer: UnsafePointer<_xmlNode>) -> String? {
        guard let value = xmlNodeGetContent(pointer) else {
            return nil
        }
        defer {
            xmlFree(value)
        }
        return parseString(from: value)
    }

    func attributes(for name: String, with pointer: UnsafePointer<_xmlNode>) -> String? {
        guard let xmlValue = xmlGetProp(pointer, name) else {
            return nil
        }
        defer {
            xmlFree(xmlValue)
        }
        return parseString(from: xmlValue)
    }

    func children(for pointer: UnsafePointer<_xmlNode>) -> [Node] {
        return PathParser.parse(
            head: pointer.pointee.children,
            createNode: Node.init(pointer:)
        )

    }
}

extension PathParser {
    static func parse(head: xmlNodePtr?, createNode: (UnsafePointer<_xmlNode>) -> Node?) -> [Node] {
        var result = [Node]()
        var current = head?.pointee.next
        while let nodeable = current, let node = createNode(nodeable) {
            result.append(node)
            current = current?.pointee.next
        }
        return result
    }
}

extension _xmlNode: Nodeable {}
