//
//  Extensions.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Clibxml2
import Foundation

extension UnsafePointer where Pointee == UInt8 {
    func UTF8Length() -> Int {
        var length = 0
        while self[length] != 0 {
            length += 1
        }
        return length
    }
}

extension Data {
    init?(nilCString: UnsafePointer<UInt8>?) {
        guard let cString = nilCString else {
            return nil
        }
        let pointer = UnsafeBufferPointer(
            start: cString,
            count: cString.UTF8Length()
        )
        self.init(buffer: pointer)
    }
}

extension String {
    init?(nilCString: UnsafePointer<UInt8>?) {
        guard let cString = nilCString else {
            return nil
        }
        self.init(cString: cString)
    }

    init?(utf8Data: Data?) {
        guard let data = utf8Data else {
            return nil
        }
        self.init(decoding: data, as: UTF8.self)
    }
}

extension UnsafePointer where Pointee == _xmlNode {
    func name() -> String {
        String(cString: pointee.name)
    }

    func nodeType() -> NodeType? {
        NodeType(rawValue: Int(pointee.type.rawValue))
    }

    func attributes() -> [String: String] {
        var attributes = [String: String]()
        var attribute = pointee.properties
        while attribute != nil {
            if let key = String(nilCString: attribute?.pointee.name), let value = self.attributes(for: key) {
                attributes[key] = value
            }
            attribute = attribute?.pointee.next
        }
        return attributes
    }

    func data() -> Data? {
        guard let value = xmlNodeGetContent(self) else {
            return nil
        }
        defer {
            xmlFree(value)
        }
        return Data(nilCString: value)
    }

    func attributes(for name: String) -> String? {
        guard let value = xmlGetProp(self, name) else {
            return nil
        }
        defer {
            xmlFree(value)
        }
        return String(nilCString: value)
    }

    func children() -> [Node] {
        guard let children = pointee.children else {
            return []
        }
        var result = [Node]()
        var current = children.pointee.next
        while let pointer = current, let node = Node(nilPointer: pointer) {
            result.append(node)
            current = current?.pointee.next
        }
        return result
    }
}
