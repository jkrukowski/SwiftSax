import XCTest
@testable import SwiftSax

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
        XCTAssertEqual(events, [.startDocument, .startDocument, .endDocument])
    }

    func testOpenHtmlElements() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: testOpenHtmlElementsString.data)
        XCTAssertEqual(events, [
            .startDocument,
            .startElement(name: "html", attribues: [:]),
            .startElement(name: "body", attribues: [:]),
            .startElement(name: "div", attribues: [:]),
            .startElement(name: "div", attribues: [:]),
            .startElement(name: "div", attribues: [:]),
            .startDocument,
            .endElement(name: "div"),
            .endElement(name: "div"),
            .endElement(name: "div"),
            .endElement(name: "body"),
            .endElement(name: "html"),
            .endDocument])
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

    static var allTests = [
        ("testEmptyData", testEmptyData),
        ("testCollect", testCollect)
    ]
}
