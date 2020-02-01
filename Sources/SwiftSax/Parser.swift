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
    open var eventHandler: ((ParserEvent) -> Void)?
    open var options: ParseOptions

    public init(options: ParseOptions = .default, eventHandler: ((ParserEvent) -> Void)? = nil) {
        self.options = options
        self.eventHandler = eventHandler
    }

    open func parse(data: Data) throws {
        var htmlParser = htmlSAXHandler()
        htmlParser.startDocument = { (context: UnsafeMutableRawPointer?) in
            let parser = Parser.from(context: context)
            parser?.eventHandler?(.startDocument)
        }
        htmlParser.endDocument = { (context: UnsafeMutableRawPointer?) in
            let parser = Parser.from(context: context)
            parser?.eventHandler?(.endDocument)
        }
        htmlParser.startElement = { (context: UnsafeMutableRawPointer?, namePointer: UnsafePointer<UInt8>?, attribuesPointer: UnsafeMutablePointer<UnsafePointer<UInt8>?>?) in
            if let name = String(nilCString: namePointer) {
                let attributes = [String: String](nilCArray: attribuesPointer)
                let parser = Parser.from(context: context)
                parser?.eventHandler?(.startElement(name: name, attribues: attributes))
            } else {
                logger.warning("Couldn't parse string in startElement")
            }
        }
        htmlParser.endElement = { (context: UnsafeMutableRawPointer?, namePointer: UnsafePointer<UInt8>?) in
            if let name = String(nilCString: namePointer) {
                let parser = Parser.from(context: context)
                parser?.eventHandler?(.endElement(name: name))
            } else {
                logger.warning("Couldn't parse string in endElement")
            }
        }
        htmlParser.characters = { (context: UnsafeMutableRawPointer?, charactersPointer: UnsafePointer<UInt8>?, _) in
            if let characters = String(nilCString: charactersPointer) {
                let parser = Parser.from(context: context)
                parser?.eventHandler?(.characters(value: characters))
            } else {
                logger.warning("Couldn't parse string in characters")
            }
        }

        _ = try data.withUnsafeBytes { (input: UnsafeRawBufferPointer) -> Int32 in
            guard let inputPointer = input.bindMemory(to: CChar.self).baseAddress else {
                logger.error("Couldn't find input pointer")
                throw ParserError.unknown
            }
            let context = Unmanaged.passUnretained(self).toOpaque()
            guard let parserContext = htmlCreatePushParserCtxt(
                &htmlParser, context, inputPointer, Int32(data.count), nil, XML_CHAR_ENCODING_NONE
            )
            else {
                logger.error("Couldn't create parser context")
                throw ParserError.unknown
            }
            defer { htmlFreeParserCtxt(parserContext) }
            let parseOptions = CInt(options.rawValue)
            htmlCtxtUseOptions(parserContext, parseOptions)
            let parseResult = htmlParseDocument(parserContext)
            if let error = ParserError(context: parserContext, parseResult: parseResult) {
                throw error
            }
            return 0
        }
    }
}
