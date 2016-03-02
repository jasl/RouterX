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

        router.matchAndDoHandler(pattern1Case)
        XCTAssertTrue(isPattern1HandlerPerformed)

        let unmatchedCase = "/articles/2/edit"
        var isUnmatchHandlerPerformed = false

        router.matchAndDoHandler(unmatchedCase, unmatchHandler: { _ in
            isUnmatchHandlerPerformed = true
        })
        XCTAssertTrue(isUnmatchHandlerPerformed)
    }

}
