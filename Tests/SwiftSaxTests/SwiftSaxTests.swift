@testable import SwiftSax
import XCTest

final class SwiftSaxTests: XCTestCase {
    func testEmptyData() {
        XCTAssertThrowsError(try Parser(data: Data()))
        XCTAssertThrowsError(try Parser(data: "".data))
        XCTAssertNoThrow(try Parser(data: " ".data))
    }

    func testInvalidXPath() throws {
        let parser = try Parser(data: " ".data)
        XCTAssertThrowsError(try parser.find(path: ""))
        XCTAssertThrowsError(try parser.find(path: "\\"))
    }

    func testXpathResult() throws {
        let parser = try Parser(data: "<div><div></div></div>".data)
        XCTAssertTrue(try parser.find(path: "//a").isEmpty)
        XCTAssertTrue(try parser.find(path: "//div[@class='some']").isEmpty)
        XCTAssertEqual(try parser.find(path: "//div").count, 2)
    }

    func testXpath() throws {
        let parser = try Parser(data: testString.data)
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
        let parser = try Parser(data: testString.data)
        var result = try parser.find(path: "//header[@class='offer-item-header']//strong")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "strong")
        XCTAssertEqual(result[0].content, "38 m")
        XCTAssertEqual(result[1].name, "strong")
        XCTAssertEqual(result[1].content, "48 m")
    }
}
