import Foundation
import XCTest
@testable import RouterX

class RoutingGraphTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testMapPlaceholders() {
        let cases: [String: [String: Int]] = [
                "/articles": [:],
                ":article": ["article": 0],
                "/page/:page": ["page": 3],
                "/:article/tab/:tab": ["article": 1, "tab": 5]
        ]

        for (pattern, expect) in cases {
            let route = RouteVertex(pattern: pattern)

            XCTAssertEqual(route.placeholderMappings, expect)
        }
    }

    func testToNextVertex() {
        let route = RouteVertex(pattern: "")
        route.nextRoutes[.Slash] = RouteVertex(pattern: "/")
        route.nextRoutes[.Dot] = RouteVertex(pattern: ".")
        route.nextRoutes[.Literal("articles")] = RouteVertex(pattern: "articles")

        XCTAssertEqual(route.toNextVertex(.Slash)?.pattern, "/")
        XCTAssertEqual(route.toNextVertex(.Dot)?.pattern, ".")
        XCTAssertEqual(route.toNextVertex(.Literal("articles"))?.pattern, "articles")

        XCTAssertNil(route.toNextVertex(.Literal("blog")))

        route.epsilonRoute = ("any", RouteVertex(pattern: "any"))

        XCTAssertEqual(route.toNextVertex(.Literal("blog"))?.pattern, "any", "Given a non-existing Literal edge should go epsilon edge if it's available.")
        XCTAssertEqual(route.toNextVertex(.Literal("articles"))?.pattern, "articles")
    }
}
