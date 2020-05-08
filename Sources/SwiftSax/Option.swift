//
//  Option.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/31/20.
//

import libxml2
import Foundation

extension Parser {
    public struct Option: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let recover = Option(rawValue: Int(HTML_PARSE_RECOVER.rawValue))
        public static let noDefaultDTD = Option(rawValue: Int(HTML_PARSE_NODEFDTD.rawValue))
        public static let noError = Option(rawValue: Int(HTML_PARSE_NOERROR.rawValue))
        public static let noWarning = Option(rawValue: Int(HTML_PARSE_NOWARNING.rawValue))
        public static let pedantic = Option(rawValue: Int(HTML_PARSE_PEDANTIC.rawValue))
        public static let noBlanks = Option(rawValue: Int(HTML_PARSE_NOBLANKS.rawValue))
        public static let noNetwork = Option(rawValue: Int(HTML_PARSE_NONET.rawValue))
        public static let noImpliedElements = Option(rawValue: Int(HTML_PARSE_NOIMPLIED.rawValue))
        public static let compactTextNodes = Option(rawValue: Int(HTML_PARSE_COMPACT.rawValue))
        public static let ignoreEncodingHint = Option(rawValue: Int(HTML_PARSE_IGNORE_ENC.rawValue))

        /// Default set of parse options.
        public static let `default`: Option = [
            .recover,
            .noBlanks,
            .noNetwork,
            .noImpliedElements,
            .compactTextNodes
        ]
    }
}
