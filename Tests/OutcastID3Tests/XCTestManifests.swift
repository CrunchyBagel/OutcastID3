import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OutcastID3Tests.allTests),
    ]
}
#endif
