@testable import SwiftSax
import XCTest

final class SwiftSaxTests: XCTestCase {
    func testEmptyData() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: Data())
        XCTAssertEqual(events, [.startDocument, .endDocument])
    }

    func testWhitespaceString() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: "  ".data)
        XCTAssertEqual(events, [.startDocument, .endDocument])
    }

    func testStringNoHtmlElements() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: "text".data)
        XCTAssertEqual(
            events,
            [
                .startDocument,
                .startElement(name: "p", attributes: [:]),
                .characters(value: "text"),
                .endElement(name: "p"),
                .endDocument
            ]
        )
    }

    func testOpenHtmlElements() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: testOpenHtmlElementsString.data)
        XCTAssertEqual(
            events,
            [
                .startDocument,
                .startElement(name: "div", attributes: [:]),
                .startElement(name: "div", attributes: [:]),
                .startElement(name: "div", attributes: [:]),
                .endElement(name: "div"),
                .endElement(name: "div"),
                .endElement(name: "div"),
                .endDocument
            ]
        )
    }

    func testClosedHtmlElements() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: testClosedHtmlElementsString.data)
        XCTAssertEqual(
            events,
            [
                .startDocument,
                .startElement(name: "div", attributes: [:]),
                .startElement(name: "div", attributes: [:]),
                .startElement(name: "div", attributes: [:]),
                .endElement(name: "div"),
                .endElement(name: "div"),
                .endElement(name: "div"),
                .endDocument
            ]
        )
    }

    func testHtmlElementsWithText() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: testHtmlElementsWithTextString.data)
        XCTAssertEqual(
            events,
            [
                .startDocument,
                .startElement(name: "div", attributes: [:]),
                .characters(value: "here"),
                .startElement(name: "div", attributes: [:]),
                .characters(value: "is"),
                .startElement(name: "div", attributes: [:]),
                .characters(value: "some"),
                .endElement(name: "div"),
                .endElement(name: "div"),
                .endElement(name: "div"),
                .endDocument
            ]
        )
    }

    func testHtml() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: testHtmlString.data)
        XCTAssertEqual(
            events,
            [
                .startDocument,
                .startElement(name: "html", attributes: [:]),
                .startElement(name: "head", attributes: [:]),
                .startElement(name: "meta", attributes: ["http-equiv": "Content-Type", "content": "text/html; charset=utf-8"]),
                .endElement(name: "meta"),
                .endElement(name: "head"),
                .startElement(name: "body", attributes: [:]),
                .startElement(name: "h1", attributes: [:]),
                .characters(value: "Heading"),
                .endElement(name: "h1"),
                .startElement(name: "p", attributes: [:]),
                .characters(value: "Paragraph"),
                .endElement(name: "p"),
                .endElement(name: "body"),
                .endElement(name: "html"),
                .endDocument
            ]
        )
    }

    func testXpath() throws {
        let parser = PathParser()
        try parser.parse(data: testCollectString.data)
        var result = try parser.find(path: "//header[@class='offer-item-header']//a/@href | //header[@class='offer-item-header']//a/@data-id")
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].name, "href")
        XCTAssertEqual(result[0].content, "https://link.com/to/offer")
        XCTAssertEqual(result[0].type, .attribute)
        XCTAssertEqual(result[0].children.count, 0)
        XCTAssertEqual(result[0].attributes.count, 0)
        XCTAssertEqual(result[1].name, "data-id")
        XCTAssertEqual(result[1].content, "666")
        XCTAssertEqual(result[1].type, .attribute)
        XCTAssertEqual(result[1].children.count, 0)
        XCTAssertEqual(result[1].attributes.count, 0)
        XCTAssertEqual(result[2].name, "href")
        XCTAssertEqual(result[2].content, "https://link.com/to/offer2")
        XCTAssertEqual(result[2].type, .attribute)
        XCTAssertEqual(result[2].children.count, 0)
        XCTAssertEqual(result[2].attributes.count, 0)
        XCTAssertEqual(result[3].name, "data-id")
        XCTAssertEqual(result[3].content, "999")
        XCTAssertEqual(result[3].type, .attribute)
        XCTAssertEqual(result[3].children.count, 0)
        XCTAssertEqual(result[3].attributes.count, 0)
    }

    func testXpath2() throws {
        let parser = PathParser()
        try parser.parse(data: testCollectString.data)
        var result = try parser.find(path: "//header[@class='offer-item-header']//strong")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "strong")
        XCTAssertEqual(result[0].content, "38 m")
        XCTAssertEqual(result[1].name, "strong")
        XCTAssertEqual(result[1].content, "48 m")
    }
}
