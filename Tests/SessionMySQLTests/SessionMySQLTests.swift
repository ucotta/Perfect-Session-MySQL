import XCTest
@testable import SessionMySQL

class SessionMySQLTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SessionMySQL().text, "Hello, World!")
    }


    static var allTests : [(String, (SessionMySQLTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
