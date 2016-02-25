import Foundation
import XCTest
@testable import RouterX

class URIPathScannerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testScanner() {
        let cases: [String: Array<URIPathToken>] = [
                "/": [.Slash],
                "//": [.Slash, .Slash],
                "/page": [.Slash, .Literal("page")],
                "/page/": [.Slash, .Literal("page"), .Slash],
                "/page!": [.Slash, .Literal("page!")],
                "/page$": [.Slash, .Literal("page$")],
                "/page&": [.Slash, .Literal("page&")],
                "/page'": [.Slash, .Literal("page'")],
                "/page*": [.Slash, .Literal("page*")],
                "/page+": [.Slash, .Literal("page+")],
                "/page,": [.Slash, .Literal("page,")],
                "/page=": [.Slash, .Literal("page=")],
                "/page@": [.Slash, .Literal("page@")],
                "/~page": [.Slash, .Literal("~page")],
                "/pa-ge": [.Slash, .Literal("pa-ge")],
                "/pa ge": [.Slash, .Literal("pa ge")],
                "/page.json": [.Slash, .Literal("page"), .Dot, .Literal("json")]
        ]

        for (pattern, expect) in cases {
            let tokens = URIPathScanner.tokenize(pattern)

            XCTAssertEqual(tokens, expect)
        }
    }

}
