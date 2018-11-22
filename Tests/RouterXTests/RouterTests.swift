import Foundation
import XCTest
@testable import RouterX

final class RouterTests: XCTestCase {
    func testIntegration() {
        let router = Router<String>()

        let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
        let pattern1Case = "/articles/page/2/sort/recent.json"
        var isPattern1HandlerPerformed = false
        let pattern1Handler: Router<String>.MatchedHandler = { result in
            isPattern1HandlerPerformed = true

            XCTAssertEqual(result.parameters["page"], "2")
            XCTAssertEqual(result.parameters["format"], "json")
            XCTAssertEqual(result.parameters["sort"], "recent")
            XCTAssertTrue(result.context == "foo", "context must be foo")
        }

        XCTAssertTrue(router.register(pattern: pattern1, handler: pattern1Handler))
        XCTAssertTrue(router.match(pattern1Case, context: "foo"))
        XCTAssertTrue(isPattern1HandlerPerformed)

        let unmatchedCase = "/articles/2/edit"
        var isUnmatchHandlerPerformed = false

        XCTAssertFalse(router.match(unmatchedCase, unmatchHandler: { (_, _) in
            isUnmatchHandlerPerformed = true
        }))
        XCTAssertTrue(isUnmatchHandlerPerformed)

        let pattern2 = "/band/:band_id/product"
        let pattern2Case1 = "/band/20/product"
        let pattern2Case2 = "/band/21"
        let pattern2Case3 = "/band"

        XCTAssertTrue(router.register(pattern: pattern2, handler: { result in
            XCTAssertEqual(result.parameters["band_id"], "20")
            XCTAssertEqual(result.parameters.count, 1)
        }))

        XCTAssertTrue(router.match(pattern2Case1))
        XCTAssertFalse(router.match(pattern2Case2))
        XCTAssertFalse(router.match(pattern2Case3))
    }
}
