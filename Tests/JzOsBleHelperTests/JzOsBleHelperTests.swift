import XCTest
@testable import JzOsBleHelper
import CoreBluetooth
final class JzOsBleHelperTests: XCTestCase {
   
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(JzOsBleHelper().text, "Hello, World!")
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
