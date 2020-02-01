
//
//  ParserError.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/30/20.
//

import Clibxml2
import Foundation

public enum ParserError: Error {
    case unknown
    case parsing(message: String, location: ErrorLocation)
}

extension ParserError {
    init?(context: UnsafeMutableRawPointer?) {
        guard let error = xmlCtxtGetLastError(context) else {
            return nil
        }
        self.init(error: error.pointee)
    }

    init?(context: UnsafeMutableRawPointer?, parseResult: CInt) {
        guard parseResult != 0 else {
            return nil
        }
        self.init(context: context)
    }

    init?(error: xmlError) {
        guard error.level == XML_ERR_FATAL else {
            return nil
        }
        let location = ErrorLocation(line: Int(error.line), column: Int(error.int2))
        if let errorMessage = error.message {
            let message = String(cString: errorMessage).trimmingCharacters(in: .whitespacesAndNewlines)
            self = .parsing(message: message, location: location)
        } else {
            self = .parsing(message: "", location: location)
        }
    }
}
