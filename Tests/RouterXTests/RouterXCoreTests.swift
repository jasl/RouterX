import Foundation
import XCTest
@testable import RouterX

final class RouterXCoreTests: XCTestCase {

    func testIntegration() {
        let core = RouterXCore()
        let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
        let pattern1Case = URL(string: "/articles/page/2/sort/recent.json")!

        XCTAssertNoThrow(try core.register(pattern: pattern1))

        guard let pattern1Matched = core.match(pattern1Case) else {
            XCTFail("\(pattern1Case) should be matched")
            return
        }

        XCTAssertEqual(pattern1Matched.patternIdentifier, pattern1)
        XCTAssertEqual(pattern1Matched.parametars["page"], "2")
        XCTAssertEqual(pattern1Matched.parametars["sort"], "recent")
        XCTAssertEqual(pattern1Matched.parametars["format"], "json")

        let unmatchedCase = URL(string: "/articles/2/edit")!

        XCTAssertNil(core.match(unmatchedCase))
    }

    func testPatternMustStartWithSlash() {
        let core = RouterXCore()
        let invalidPattern = "invalid/:id"
        let validPattern = "/valid/:id"

        XCTAssertThrowsError(try core.register(pattern: invalidPattern), "Must be start with slash") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .missingPrefixSlash = expectError {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }
        XCTAssertNoThrow(try core.register(pattern: validPattern))
    }

    func testPatternCanNotRegisterEmpty() {
        let core = RouterXCore()
        let invalidPattern = ""
        let validPattern = "/valid/:id"

        XCTAssertThrowsError(try core.register(pattern: invalidPattern), "Can not register an empty pattern") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .empty = expectError {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }
        XCTAssertNoThrow(try core.register(pattern: validPattern))
    }

    func testPatternGlobbingMustFollowSlash() {
        let core = RouterXCore()
        let invalidPattern1 = "/slash/body*"
        let invalidPattern2 = "/slash/:id*name"
        let validPattern = "/valid/:id"

        XCTAssertThrowsError(try core.register(pattern: invalidPattern1), "globbing must follow slash") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .invalidGlobbing(let globbing, let previous) = expectError {
                if globbing == "" && previous == "/slash/body" {
                    succeed = true
                }
                XCTAssert(succeed, "invalid scanned result")
            }
            XCTAssertTrue(succeed)
        }

        XCTAssertThrowsError(try core.register(pattern: invalidPattern2), "globbing must follow slash") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .invalidGlobbing(let globbing, let previous) = expectError {
                if globbing == "name" && previous == "/slash/:id" {
                    succeed = true
                }
                XCTAssert(succeed, "invalid scanned result")
            }
            XCTAssertTrue(succeed)
        }

        XCTAssertNoThrow(try core.register(pattern: validPattern))
    }

    func testPatternParenthesisMustComeInPairsAndBalance() {
        var core = RouterXCore()
        let invalidSingleParenthesisPattern = "/invalid(/foo/:foo"
        let validSingleeParenthesisPattern = "/valid/(/foo/:foo)"

        XCTAssertThrowsError(try core.register(pattern: invalidSingleParenthesisPattern), "Parenthesis in pattern must come in pairs") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .unbalanceParenthesis = expectError {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }
        XCTAssertNoThrow(try core.register(pattern: validSingleeParenthesisPattern))

        core = RouterXCore()
        let invalidMultipleParenthesisPattern1 = "/invalid(/foo/:foo(/bar/:bar)"
        let validMultipleParenthesisPattern1 = "/invalid(/foo/:foo(/bar/:bar))"

        XCTAssertThrowsError(try core.register(pattern: invalidMultipleParenthesisPattern1), "Parenthesis in pattern must come in pairs") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .unbalanceParenthesis = expectError {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }
        XCTAssertNoThrow(try core.register(pattern: validMultipleParenthesisPattern1))

        core = RouterXCore()
        let invalidMultipleParenthesisPattern2 = "/invalid(/foo/:foo(/bar/:bar(/zoo/:zoo))"
        let validMultipleParenthesisPattern2 = "/invalid(/foo/:foo(/bar/:bar(/zoo/:zoo)))"

        XCTAssertThrowsError(try core.register(pattern: invalidMultipleParenthesisPattern2), "Parenthesis in pattern must come in pairs") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .unbalanceParenthesis = expectError {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }

        XCTAssertNoThrow(try core.register(pattern: validMultipleParenthesisPattern2))

        core = RouterXCore()
        let invalidMultipleParenthesisPattern3 = "/invalid(/foo/:foo(/bar/:bar))(/zoo/:zoo"
        let validMultipleParenthesisPattern3 = "/invalid(/foo/:foo(/bar/:bar))(/zoo/:zoo)"

        XCTAssertThrowsError(try core.register(pattern: invalidMultipleParenthesisPattern3), "Parenthesis in pattern must come in pairs") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case .unbalanceParenthesis = expectError {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }
        XCTAssertNoThrow(try core.register(pattern: validMultipleParenthesisPattern3))

        core = RouterXCore()
        let invalidMultipleParenthesisPattern4 = "/invalid)/foo/:foo("
        let validMultipleParenthesisPattern4 = "/invalid(/foo/:foo(/bar/:bar))(/zoo/:zoo)"

        XCTAssertThrowsError(try core.register(pattern: invalidMultipleParenthesisPattern4), "Parenthesis in pattern must come in pairs, and balance") { error in
            var succeed = false
            if let expectError = error as? PatternRegisterError,
                case PatternRegisterError.unexpectToken(after: let previous) = expectError,
                previous == "/invalid" {
                succeed = true
            }
            XCTAssertTrue(succeed)
        }
        XCTAssertNoThrow(try core.register(pattern: validMultipleParenthesisPattern4))
    }
}
