import XCTest
@testable import Haby

final class Haby_Unit_Tests: XCTestCase {

    override func setUpWithError() throws {
        DIContainer.shared.registerDependencies()
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
    }

}
