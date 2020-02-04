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
                parser?.eventHandler?(.startElement(name: name, attributes: attributes))
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

open class PathParser {
    open var options: ParseOptions
    private var parserContext: htmlDocPtr?

    public init(options: ParseOptions = .default) {
        self.options = options
    }

    open func parse(data: Data) throws {
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

extension Node {
    static func from(xpath: xmlXPathObjectPtr) -> [Node] {
        var result = [Node]()
        guard let nodeSet = xpath.pointee.nodesetval else {
            return result
        }
        let endIndex = nodeSet.pointee.nodeNr
        let nodeTab = nodeSet.pointee.nodeTab
        for index in 0..<endIndex {
            if let rawNode = nodeTab?[Int(index)], let node = Node(node: rawNode.pointee) {
                result.append(node)
            }
        }
        return result
    }
}

public enum NodeType: Int {
    case element = 1
    case attribute = 2
    case text = 3
    case cdataSection = 4
    case entityReference = 5
    case entity = 6
    case pi = 7
    case comment = 8
    case document = 9
    case documentType = 10
    case documentFragment = 11
    case notation = 12
    case htmlDocument = 13
    case dtd = 14
    case elementDeclaration = 15
    case attributeDeclaration = 16
    case entityDeclaration = 17
    case namespace = 18
    case xincludeStart = 19
    case xincludeEnd = 20
}

public struct Node {
    public var type: NodeType
    public var name: String
    public var children: [Node]
    public var attributes: [Node]
    public var content: String?
}

protocol Attributable {
    var type: xmlElementType { get }
    var name: UnsafePointer<xmlChar>! { get }
    var children: UnsafeMutablePointer<_xmlNode>! { get }
}

extension Attributable {
    var nodeType: NodeType? {
        NodeType(rawValue: Int(type.rawValue))
    }

    var nameString: String {
        return String(cString: name)
    }

    var childrenNodes: [Node] {
        var nodeChildren = [Node]()
        var hasChildren = children != nil
        var current = children
        while hasChildren {
            if let pointer = current, let c = Node(node: pointer.pointee) {
                nodeChildren.append(c)
                current = current?.successor()
            } else {
                hasChildren = false
            }
        }
        return nodeChildren
    }
}

protocol Nodable: Attributable {
    var content: UnsafeMutablePointer<xmlChar>! { get }
    var properties: UnsafeMutablePointer<_xmlAttr>! { get }
}

extension Nodable {
    var attributeNodes: [Node] {
        var nodeAttributes = [Node]()
        var hasAttributes = properties != nil
        var attributes = properties
        while hasAttributes {
            if let pointer = attributes, let c = Node(attribute: pointer.pointee) {
                nodeAttributes.append(c)
                attributes = attributes?.successor()
            } else {
                hasAttributes = false
            }
        }
        return nodeAttributes
    }
}

extension Nodable {
    var contentString: String? {
        guard let cString = content else {
            return nil
        }
        return String(cString: cString)
    }
}

extension _xmlNode: Nodable {
}

extension _xmlAttr: Attributable {

}

extension Node {
    init?(attribute: Attributable) {
        guard let type = attribute.nodeType else {
            return nil
        }
        self.type = type
        self.name = attribute.nameString
        self.content = nil
        self.children = attribute.childrenNodes
        self.attributes = []
    }

    init?(node: Nodable) {
        guard let type = node.nodeType else {
            return nil
        }
        self.type = type
        self.name = node.nameString
        self.content = node.contentString
        self.children = node.childrenNodes
        self.attributes = node.attributeNodes
    }
}
