//
//  Parser.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/29/20.
//

import Clibxml2
import Foundation
import Logging

let logger = Logger(label: "SwiftSax.Parser")

open class Parser {
    open var options: Parser.Option
    private let parserContext: htmlDocPtr

    public init(options: Parser.Option = .default, data: Data) throws {
        self.options = options
        let inputPointer = try data.withUnsafeBytes { (input: UnsafeRawBufferPointer) -> UnsafePointer<CChar> in
            guard let inputPointer = input.bindMemory(to: CChar.self).baseAddress else {
                logger.error("Couldn't find input pointer")
                throw ParserError.unknown
            }
            return inputPointer
        }
        let parseOptions = CInt(options.rawValue)
        guard let parserContext = htmlReadMemory(inputPointer, Int32(data.count), "", nil, parseOptions) else {
            logger.error("Couldn't create parser context")
            throw ParserError.unknown
        }
        self.parserContext = parserContext
    }

    open func find(path: String) throws -> [Node] {
        guard let xpathContext = xmlXPathNewContext(parserContext) else {
            logger.error("Couldn't create xPath context")
            throw ParserError.unknown
        }
        defer { xmlXPathFreeContext(xpathContext) }
        guard let xpath = xmlXPathEvalExpression(path, xpathContext) else {
            logger.error("Couldn't evaluate xPath expression")
            throw ParserError.unknown
        }
        return Node.from(xpath: xpath)
    }

    deinit {
        xmlFreeDoc(parserContext)
    }
}
