import XCTest
@testable import SwiftSax

final class SwiftSaxTests: XCTestCase {
    func testEmpty() throws {
        var events = [ParserEvent]()
        let parser = Parser()
        parser.eventHandler = { event in
            events.append(event)
        }
        try parser.parse(data: Data())
        XCTAssertEqual(events, [ParserEvent.startDocument, ParserEvent.endDocument])
    }

    func testCollect() throws {
        let data = data1.data(using: .utf8)!
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
            data: data,
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
        ("testEmpty", testEmpty),
        ("testCollect", testCollect)
    ]
}
