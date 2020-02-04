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

//struct _xmlNode {
//    void           *_private;    /* application data */
//    xmlElementType   type;    /* type number, must be second ! */
//    const xmlChar   *name;      /* the name of the node, or the entity */
//    struct _xmlNode *children;    /* parent->childs link */
//    struct _xmlNode *last;    /* last child link */
//    struct _xmlNode *parent;    /* child->parent link */
//    struct _xmlNode *next;    /* next sibling link  */
//    struct _xmlNode *prev;    /* previous sibling link  */
//    struct _xmlDoc  *doc;    /* the containing document */
//
//    /* End of common part */
//    xmlNs           *ns;        /* pointer to the associated namespace */
//    xmlChar         *content;   /* the content */
//    struct _xmlAttr *properties;/* properties list */
//    xmlNs           *nsDef;     /* namespace definitions on this node */
//    void            *psvi;    /* for type/PSVI informations */
//    unsigned short   line;    /* line number */
//    unsigned short   extra;    /* extra data for XPath/XSLT */
//};

//struct _xmlAttr {
//    void           *_private;    /* application data */
//    xmlElementType   type;      /* XML_ATTRIBUTE_NODE, must be second ! */
//    const xmlChar   *name;      /* the name of the property */
//    struct _xmlNode *children;    /* the value of the property */
//    struct _xmlNode *last;    /* NULL */
//    struct _xmlNode *parent;    /* child->parent link */
//    struct _xmlAttr *next;    /* next sibling link  */
//    struct _xmlAttr *prev;    /* previous sibling link  */
//    struct _xmlDoc  *doc;    /* the containing document */
//    xmlNs           *ns;        /* pointer to the associated namespace */
//    xmlAttributeType atype;     /* the attribute type if validating */
//    void            *psvi;    /* for type/PSVI informations */
//};

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

extension Node {
    init?(attribute: _xmlAttr) {
        guard let type = NodeType(rawValue: Int(attribute.type.rawValue)) else {
            return nil
        }
        self.type = type
        self.name = String(cString: attribute.name)
        self.content = nil
        var nodeChildren = [Node]()
        var hasChildren = attribute.children != nil
        var children = attribute.children
        while hasChildren {
            if let pointer = children, let c = Node(node: pointer.pointee) {
                nodeChildren.append(c)
                children = children?.successor()
            } else {
                hasChildren = false
            }
        }
        self.children = nodeChildren
        self.attributes = []
    }

    init?(node: _xmlNode) {
        guard let type = NodeType(rawValue: Int(node.type.rawValue)) else {
            return nil
        }
        self.type = type
        self.name = String(cString: node.name)
        if let content = node.content {
            self.content = String(cString: content)
        } else {
            self.content = nil
        }
        var nodeChildren = [Node]()
        var hasChildren = node.children != nil
        var children = node.children
        while hasChildren {
            if let pointer = children, let c = Node(node: pointer.pointee) {
                nodeChildren.append(c)
                children = children?.successor()
            } else {
                hasChildren = false
            }
        }
        self.children = nodeChildren

        var nodeAttributes = [Node]()
        var hasAttributes = node.properties != nil
        var attributes = node.properties
        while hasAttributes {
            if let pointer = attributes, let c = Node(attribute: pointer.pointee) {
                nodeAttributes.append(c)
                attributes = attributes?.successor()
            } else {
                hasAttributes = false
            }
        }
        self.attributes = nodeAttributes
    }

}
