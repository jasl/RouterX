import Foundation
import XCTest
@testable import RouterX

class RoutingPatternParserTests: XCTestCase {
    let blankTerminalHandler: RouteTerminalHandler = { _ in }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testParsingFailureShouldThrowError() {
        let badTokens: [RoutingPatternToken] = [.RParen, .Literal("bad")]
        let route = RouteVertex()
        let parser = RoutingPatternParser(routingPatternTokens: badTokens, terminalHandler: blankTerminalHandler)

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
            tokens = [.Slash]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.Slash))

            let cases: [[RoutingPatternToken]] = [
                    [.Slash, .Literal("me")],
                    [.Slash, .Symbol("foo")],
                    [.Slash, .Star("foo")],
                    [.Slash, .LParen, .RParen]
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.Slash, .RParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
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
            tokens = [.Slash, .Literal("foo"), .Dot]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }

        do {
            let cases: [[RoutingPatternToken]] = [
                    [.Slash, .Literal("foo"), .Dot, .Literal("me")],
                    [.Slash, .Literal("foo"), .Dot, .Symbol("foo")],
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)

                XCTAssertNotNil(route.toNextVertex(.Slash)?.toNextVertex(.Literal("foo"))?.toNextVertex(.Dot))
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.Slash, .Literal("foo"), .Dot, .Dot]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
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
            tokens = [.Slash, .Literal("articles")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.Slash)?.toNextVertex(.Literal("articles")))

            let cases: [[RoutingPatternToken]] = [
                    [.Slash, .Literal("me"), .Slash],
                    [.Slash, .Literal("me"), .Dot, .Literal("bar")],
                    [.Slash, .Literal("me"), .LParen, .RParen]
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.Slash, .Literal("foo"), .Literal("bar")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
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
            tokens = [.Slash, .Symbol("id")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.Slash)?.toNextVertex(.Literal("123")))

            let cases: [[RoutingPatternToken]] = [
                    [.Slash, .Symbol("id"), .Slash],
                    [.Slash, .Symbol("id"), .Dot, .Literal("js")],
                    [.Slash, .Symbol("id"), .LParen, .RParen]
            ]

            for tokens in cases {
                parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
                route = RouteVertex()

                try parser.parseAndAppendTo(route)
            }
        } catch {
            XCTFail("Should not throw errors")
        }

        do {
            tokens = [.Slash, .Symbol("foo"), .Symbol("bar")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
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
            tokens = [.Slash, .Star("info"), .Slash]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }

        do {
            tokens = [.Slash, .Star("info")]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            XCTAssertNotNil(route.toNextVertex(.Slash)?.toNextVertex(.Literal("123")))
        } catch {
            XCTFail("Should not throw errors")
        }
    }

    func testParseLParen() {
        var parser: RoutingPatternParser!
        var route: RouteVertex!
        var tokens: [RoutingPatternToken]!

        do {
            tokens = [.Slash, .LParen, .LParen, .RParen, .RParen, .RParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()
            try parser.parseAndAppendTo(route)

            XCTFail("Should throw errors")
        } catch { }

        do {
            tokens = [.Slash, .LParen, .Slash, .Literal("test"), .RParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)

            tokens = [.Slash, .LParen, .Slash, .Literal("test"), .RParen, .LParen, .Slash, .Symbol("foo"), .RParen]
            parser = RoutingPatternParser(routingPatternTokens: tokens, terminalHandler: blankTerminalHandler)
            route = RouteVertex()

            try parser.parseAndAppendTo(route)
        } catch {
            XCTFail("Should not throw errors")
        }
    }
}
