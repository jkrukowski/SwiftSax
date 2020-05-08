//
//  Parser.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/29/20.
//

#if os(Linux)
import Clibxml2
#else
import libxml2
#endif
import Foundation

open class Parser {
    open var options: Parser.Option
    private let parserContext: htmlDocPtr

    public init(options: Parser.Option = .default, data: Data) throws {
        self.options = options
        let inputPointer = try data.withUnsafeBytes { (input: UnsafeRawBufferPointer) -> UnsafePointer<CChar> in
            guard let inputPointer = input.bindMemory(to: CChar.self).baseAddress else {
                throw ParserError.data
            }
            return inputPointer
        }
        let parseOptions = CInt(options.rawValue)
        guard let parserContext = htmlReadMemory(inputPointer, Int32(data.count), "", nil, parseOptions) else {
            throw ParserError.context
        }
        self.parserContext = parserContext
    }

    open func find(path: String) throws -> [Node] {
        guard let xpathContext = xmlXPathNewContext(parserContext) else {
            throw ParserError.context
        }
        defer { xmlXPathFreeContext(xpathContext) }
        guard let xpath = xmlXPathEvalExpression(path, xpathContext) else {
            throw ParserError.xpath
        }
        defer { xmlXPathFreeObject(xpath) }
        return Node.from(xpath: xpath)
    }

    deinit {
        xmlFreeDoc(parserContext)
    }
}
