import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JzOsBleHelperTests.allTests),
    ]
}
#endif
