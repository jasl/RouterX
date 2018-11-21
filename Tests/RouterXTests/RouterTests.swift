import Foundation
import XCTest
@testable import RouterX

final class RouterTests: XCTestCase {
    func testIntegration() {
        let router = Router()

        let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
        let pattern1Case = "/articles/page/2/sort/recent.json"
        var isPattern1HandlerPerformed = false
        let pattern1Handler: MatchRouteHandler = { url, parameters, context in
            isPattern1HandlerPerformed = true

            XCTAssertEqual(parameters["page"], "2")
            XCTAssertEqual(parameters["format"], "json")
            XCTAssertEqual(parameters["sort"], "recent")

            if let context = context as? String {
                XCTAssertEqual(context, "foo")
            } else {
                XCTFail("context shouldn't be nil")
            }
        }

        XCTAssertTrue(router.register(pattern: pattern1, handler: pattern1Handler))

        XCTAssertTrue(router.match(urlPath: pattern1Case, context: "foo" as AnyObject?))
        XCTAssertTrue(isPattern1HandlerPerformed)

        let unmatchedCase = "/articles/2/edit"
        var isUnmatchHandlerPerformed = false

        XCTAssertFalse(router.match(urlPath: unmatchedCase, unmatchHandler: { (_, _) in
            isUnmatchHandlerPerformed = true
        }))
        XCTAssertTrue(isUnmatchHandlerPerformed)

        let pattern2 = "/band/:band_id/product"
        let pattern2Case1 = "/band/20/product"
        let pattern2Case2 = "/band/21"
        let pattern2Case3 = "/band"

        XCTAssertTrue(router.register(pattern: pattern2, handler: { _, parameters, _ in
            XCTAssertEqual(parameters["band_id"], "20")
            XCTAssertEqual(parameters.count, 1)
        }))

        XCTAssertTrue(router.match(urlPath: pattern2Case1))
        XCTAssertFalse(router.match(urlPath: pattern2Case2))
        XCTAssertFalse(router.match(urlPath: pattern2Case3))
    }
}
