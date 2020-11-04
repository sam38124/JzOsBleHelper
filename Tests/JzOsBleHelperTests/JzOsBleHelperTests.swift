import XCTest
@testable import JzOsBleHelper
import CoreBluetooth
final class JzOsBleHelperTests: XCTestCase,BleCallBack {
    func onConnecting() {
        
    }
    
    func onConnectFalse() {
        
    }
    
    func onConnectSuccess() {
        
    }
    
    func rx(_ a: BleBinary) {
        
    }
    
    func tx(_ b: BleBinary) {
        
    }
    
    func scanBack(_ device: CBPeripheral) {
    }
    
    func needOpen() {
        
    }
    lazy var helper=BleHelper(self)
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(JzOsBleHelper().text, "Hello, World!")
        helper.startScan()
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
