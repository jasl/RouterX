import Foundation
import XCTest
@testable import RouterX

class URLPathScannerTests: XCTestCase {
    static var allTests = [
        ("testScanner", testScanner)
    ]

    func testScanner() {
        let cases: [String: Array<URLPathToken>] = [
                "/": [.slash],
                "//": [.slash, .slash],
                "/page": [.slash, .literal("page")],
                "/page/": [.slash, .literal("page"), .slash],
                "/page!": [.slash, .literal("page!")],
                "/page$": [.slash, .literal("page$")],
                "/page&": [.slash, .literal("page&")],
                "/page'": [.slash, .literal("page'")],
                "/page*": [.slash, .literal("page*")],
                "/page+": [.slash, .literal("page+")],
                "/page,": [.slash, .literal("page,")],
                "/page=": [.slash, .literal("page=")],
                "/page@": [.slash, .literal("page@")],
                "/~page": [.slash, .literal("~page")],
                "/pa-ge": [.slash, .literal("pa-ge")],
                "/pa ge": [.slash, .literal("pa ge")],
                "/page.json": [.slash, .literal("page"), .dot, .literal("json")]
        ]

        for (pattern, expect) in cases {
            let tokens = URLPathScanner.tokenize(pattern)

            XCTAssertEqual(tokens, expect)
        }
    }

}
