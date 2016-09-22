import Foundation
import XCTest
@testable import RouterX

class RoutingPatternParserTests: XCTestCase {
    let patternIdentifier: RouterX.PatternIdentifier = 1

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testParsingFailureShouldThrowError() {
        let badTokens: [RoutingPatternToken] = [.rParen, .literal("bad")]
        let route = RouteVertex()
        let parser = RoutingPatternParser(routingPatternTokens: badTokens, patternIdentifier: self.patternIdentifier)

        do {
            try parser.parseAndAppendTo(route)
            XCTFail("Parse bad pattern should throw error.")
        } catch { }
    }

    func testParseSlash() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.slash]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.slash))

            let cases: [[RoutingPatternToken]] = [
                    [.slash, .literal("me")],
                    [.slash, .symbol("foo")],
                    [.slash, .star("foo")],
                    [.slash, .lParen, .rParen]
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.slash, .rParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }
    }

    func testParseDot() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.slash, .literal("foo"), .dot]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }

        do {
            let cases: [[RoutingPatternToken]] = [
                    [.slash, .literal("foo"), .dot, .literal("me")],
                    [.slash, .literal("foo"), .dot, .symbol("foo")],
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)

                XCTAssertNotNil(route.toNextVertex(.slash)?.toNextVertex(.literal("foo"))?.toNextVertex(.dot))
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.slash, .literal("foo"), .dot, .dot]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }
    }

    func testParseLiteral() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.slash, .literal("articles")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.slash)?.toNextVertex(.literal("articles")))

            let cases: [[RoutingPatternToken]] = [
                    [.slash, .literal("me"), .slash],
                    [.slash, .literal("me"), .dot, .literal("bar")],
                    [.slash, .literal("me"), .lParen, .rParen]
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.slash, .literal("foo"), .literal("bar")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }
    }

    func testParseSymbol() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.slash, .symbol("id")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.slash)?.toNextVertex(.literal("123")))

            let cases: [[RoutingPatternToken]] = [
                    [.slash, .symbol("id"), .slash],
                    [.slash, .symbol("id"), .dot, .literal("js")],
                    [.slash, .symbol("id"), .lParen, .rParen]
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.slash, .symbol("foo"), .symbol("bar")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }
    }

    func testStar() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.slash, .star("info"), .slash]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }

        do {
            tokens = [.slash, .star("info")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.slash)?.toNextVertex(.literal("123")))
        } catch {
            XCTFail("Should not throw errors")
        }
    }

    func testParseLParen() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.slash, .lParen, .lParen, .rParen, .rParen, .rParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }

        do {
            tokens = [.slash, .lParen, .slash, .literal("test"), .rParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            tokens = [.slash, .lParen, .slash, .literal("test"), .rParen, .lParen, .slash, .symbol("foo"), .rParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, patternIdentifier: self.patternIdentifier)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)
        } catch {
            XCTFail("Should not throw errors")
        }
    }
}
