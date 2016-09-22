import Foundation
import XCTest
@testable import RouterX

class RoutingPatternScannerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testScanner() {
        let cases: [String: Array<RoutingPatternToken>] = [
                "/": [.slash],
                "*omg": [.star("omg")],
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
                "/:page": [.slash, .symbol("page")],
                "/(:page)": [.slash, .lParen, .symbol("page"), .rParen],
                "(/:action)": [.lParen, .slash, .symbol("action"), .rParen],
                "(())": [.lParen, .lParen, .rParen, .rParen],
                "(.:format)": [.lParen, .dot, .symbol("format"), .rParen]
        ]

        for (pattern, expect) in cases {
            let tokens = RoutingPatternScanner.tokenize(pattern)

            XCTAssertEqual(tokens, expect)
        }
    }

    func testRoundTrip() {
        let cases = [
                "/",
                 "/foo",
                 "/foo/bar",
                 "/foo/:id",
                 "/:foo",
                 "(/:foo)",
                 "(/:foo)(/:bar)",
                 "(/:foo(/:bar))",
                 ".:format",
                 ".xml",
                 "/foo.:bar",
                 "/foo(/:action)",
                 "/foo(/:action)(/:bar)",
                 "/foo(/:action(/:bar))",
                 "*foo",
                 "/*foo",
                 "/bar/*foo",
                 "/bar/(*foo)",
                 "/sprockets.js(.:format)",
                 "/(:locale)(.:format)"
        ]

        for pattern in cases {
            let tokens = RoutingPatternScanner.tokenize(pattern)
            let roundTripPattern = tokens.reduce("") { ($0 as String) + String(describing: $1) }

            XCTAssertEqual(roundTripPattern, pattern)
        }
    }
}
