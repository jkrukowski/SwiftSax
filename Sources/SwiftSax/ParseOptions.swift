//
//  ParseOptions.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/31/20.
//

import Clibxml2
import Foundation

public struct ParseOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let recover = ParseOptions(rawValue: Int(HTML_PARSE_RECOVER.rawValue))
    public static let noDefaultDTD = ParseOptions(rawValue: Int(HTML_PARSE_NODEFDTD.rawValue))
    public static let noError = ParseOptions(rawValue: Int(HTML_PARSE_NOERROR.rawValue))
    public static let noWarning = ParseOptions(rawValue: Int(HTML_PARSE_NOWARNING.rawValue))
    public static let pedantic = ParseOptions(rawValue: Int(HTML_PARSE_PEDANTIC.rawValue))
    public static let noBlanks = ParseOptions(rawValue: Int(HTML_PARSE_NOBLANKS.rawValue))
    public static let noNetwork = ParseOptions(rawValue: Int(HTML_PARSE_NONET.rawValue))
    public static let noImpliedElements = ParseOptions(rawValue: Int(HTML_PARSE_NOIMPLIED.rawValue))
    public static let compactTextNodes = ParseOptions(rawValue: Int(HTML_PARSE_COMPACT.rawValue))
    public static let ignoreEncodingHint = ParseOptions(rawValue: Int(HTML_PARSE_IGNORE_ENC.rawValue))

    /// Default set of parse options.
    public static let `default`: ParseOptions = [
        .recover,
        .noBlanks,
        .noNetwork,
        .noImpliedElements,
        .compactTextNodes
    ]
}
