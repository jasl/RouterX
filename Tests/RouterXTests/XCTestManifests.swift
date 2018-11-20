import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RouterTests.allTests),
        testCase(RouterXCoreTests.allTests),
        testCase(RoutingPatternParserTests.allTests),
        testCase(RoutingPatternScannerTests.allTests),
        testCase(URLPathScannerTests.allTests)
    ]
}
#endif
