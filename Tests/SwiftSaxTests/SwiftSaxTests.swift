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
                .startElement(name: "p", attribues: [:]),
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
                .startElement(name: "div", attribues: [:]),
                .startElement(name: "div", attribues: [:]),
                .startElement(name: "div", attribues: [:]),
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
                .startElement(name: "div", attribues: [:]),
                .startElement(name: "div", attribues: [:]),
                .startElement(name: "div", attribues: [:]),
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
                .startElement(name: "div", attribues: [:]),
                .characters(value: "here"),
                .startElement(name: "div", attribues: [:]),
                .characters(value: "is"),
                .startElement(name: "div", attribues: [:]),
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
                .startElement(name: "html", attribues: [:]),
                .startElement(name: "head", attribues: [:]),
                .startElement(name: "meta", attribues: ["http-equiv": "Content-Type", "content": "text/html; charset=utf-8"]),
                .endElement(name: "meta"),
                .endElement(name: "head"),
                .startElement(name: "body", attribues: [:]),
                .startElement(name: "h1", attribues: [:]),
                .characters(value: "Heading"),
                .endElement(name: "h1"),
                .startElement(name: "p", attribues: [:]),
                .characters(value: "Paragraph"),
                .endElement(name: "p"),
                .endElement(name: "body"),
                .endElement(name: "html"),
                .endDocument
            ]
        )
    }

    func testCollect() throws {
        let parser = Parser()
        let start: (ParserEvent) -> Bool = {
            $0.filterStart(
                name: equals("header"),
                attribute: has(key: "class", value: "offer-item-header")
            )
        }
        let stop: (ParserEvent) -> Bool = {
            $0.filterEnd(name: equals("header"))
        }
        let isIncluded: (ParserEvent) -> Bool = {
            $0.filterStart(
                name: equals("a"),
                attribute: has(key: "href")
            )
        }
        let result = try parser.collect(
            data: testCollectString.data,
            start: start,
            stop: stop,
            isIncluded: isIncluded
        )
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].count, 1)
        XCTAssertEqual(result[1].count, 1)
        XCTAssertNotNil(result[0][0].attributes?["href"])
        XCTAssertNotNil(result[1][0].attributes?["href"])
        XCTAssertEqual(result[0][0].name, "a")
        XCTAssertEqual(result[1][0].name, "a")
    }

    func testCollectMultiple() throws {
        let parser = Parser()
        let start: (ParserEvent) -> Bool = {
            $0.filterStart(
                name: equals("div"),
                attribute: has(key: "class", value: "select")
            )
        }
        let stop: (ParserEvent) -> Bool = {
            $0.filterEnd(name: equals("div"))
        }
        let result = try parser.collect(
            data: testCollectMultipleString.data,
            start: start,
            stop: stop
        )
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(
            result[0],
            [
                .startElement(name: "div", attribues: ["class": "select"]),
                .startElement(name: "div", attribues: [:]),
                .endElement(name: "div")
            ]
        )
    }

    static var allTests = [
        ("testEmptyData", testEmptyData),
        ("testWhitespaceString", testWhitespaceString),
        ("testStringNoHtmlElements", testStringNoHtmlElements),
        ("testOpenHtmlElements", testOpenHtmlElements),
        ("testClosedHtmlElements", testClosedHtmlElements),
        ("testHtmlElementsWithText", testHtmlElementsWithText),
        ("testHtml", testHtml),
        ("testCollect", testCollect)
    ]
}
