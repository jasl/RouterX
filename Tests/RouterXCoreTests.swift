import Foundation
import XCTest
@testable import RouterX

class RouterXCoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIntegration() {
        let router = RouterXCore()

        let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
        let pattern1Case = URL(string: "/articles/page/2/sort/recent.json")!
        let pattern1Identifier = 1

        XCTAssertTrue(router.registerRoutingPattern(pattern1, patternIdentifier: pattern1Identifier))

        guard let pattern1Matched = router.matchURL(pattern1Case as URL) else {
            XCTFail("\(pattern1Case) should be matched")
            return
        }

        XCTAssertEqual(pattern1Matched.patternIdentifier, pattern1Identifier)
        XCTAssertEqual(pattern1Matched.parametars["page"], "2")
        XCTAssertEqual(pattern1Matched.parametars["sort"], "recent")
        XCTAssertEqual(pattern1Matched.parametars["format"], "json")

        let unmatchedCase = URL(string: "/articles/2/edit")!

        XCTAssertNil(router.matchURL(unmatchedCase as URL))
    }

}
