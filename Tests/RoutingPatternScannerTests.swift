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
                "/": [.Slash],
                "*omg": [.Star("omg")],
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
                "/:page": [.Slash, .Symbol("page")],
                "/(:page)": [.Slash, .LParen, .Symbol("page"), .RParen],
                "(/:action)": [.LParen, .Slash, .Symbol("action"), .RParen],
                "(())": [.LParen, .LParen, .RParen, .RParen],
                "(.:format)": [.LParen, .Dot, .Symbol("format"), .RParen]
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
            let roundTripPattern = tokens.reduce("") { ($0 as String) + String($1) }

            XCTAssertEqual(roundTripPattern, pattern)
        }
    }
}
