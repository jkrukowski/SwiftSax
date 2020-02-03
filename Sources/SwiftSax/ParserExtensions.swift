//
//  ParserExtensions.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/29/20.
//

import Clibxml2
import Foundation

extension Parser {
    static func from(context: UnsafeMutableRawPointer?) -> Parser? {
        guard let context = context else {
            return nil
        }
        return Unmanaged<Parser>.fromOpaque(context).takeUnretainedValue()
    }
}

extension Dictionary where Key == String, Value == String {
    init(nilCArray: UnsafeMutablePointer<UnsafePointer<UInt8>?>?) {
        var result = [Key: Value]()
        var offset: UnsafePointer<UInt8>.Stride = 0
        var values = [String]()
        while let pointerValue = nilCArray?[offset] {
            values.append(String(cString: pointerValue))
            if values.count == 2 {
                let value = values.removeLast()
                let key = values.removeLast()
                result[key] = value
            }
            offset += 1
        }
        self = result
    }
}

extension String {
    init?(nilCString: UnsafePointer<UInt8>?) {
        guard let cString = nilCString else {
            return nil
        }
        self.init(cString: cString)
    }
}
