//
//  Nodeable.swift
//  Logging
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

protocol Nodeable { //}: Attributeable {
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

    func attributes(for name: String, with pointer: UnsafePointer<_xmlNode>) -> String? {
        var value: String? = nil
        if let xmlValue = xmlGetProp(pointer, name) {
            value = parseString(from: xmlValue)
            xmlFree(xmlValue)
        }
        return value
    }

    var childrenNodes: [Node] {
        []
//        PathParser.parse(
//            next: children?.pointee,
//            createNode: Node.init(nodeable:)
//        )
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
