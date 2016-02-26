import Foundation
import XCTest
@testable import RouterX

class RouterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIntegration() {
        let router = Router()

        let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
        let pattern1Case = "/articles/page/2/sort/recent.json"
        var isPattern1HandlerPerformed = false
        let pattern1Handler: RouteTerminalHandlerType = { parameters in
            isPattern1HandlerPerformed = true

            XCTAssertEqual(parameters["page"], "2")
            XCTAssertEqual(parameters["format"], "json")
            XCTAssertEqual(parameters["sort"], "recent")
        }

        try! router.registerRoutingPattern(pattern1, handler: pattern1Handler)

        switch router.matchRoute(pattern1Case) {
        case let .Matched(parameters, handler, _):
            handler(parameters)
            XCTAssertTrue(isPattern1HandlerPerformed)
        case .UnMatched:
            XCTFail("A should matched case but not matched")
        }

        let unmatchedCase = "/articles/2/edit"

        switch router.matchRoute(unmatchedCase) {
        case .Matched(_, _, _):
            XCTFail("A shouldn't matched case but matched")
        case .UnMatched:
            break
        }
    }

}
