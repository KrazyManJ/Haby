import XCTest

final class Haby_Overview_UI_Tests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}
    
    func testOverviewDisplay() throws {
        let app = XCUIApplication()
        app.launch()
        
        let streakButton = app.navigationBars.buttons[.MainTabView_StreakToolbarItem]
        
        let streakText = streakButton.staticTexts[.StreakToolbarItem_StreakText]
        XCTAssertTrue(streakText.exists)
        XCTAssertEqual(streakText.label, "2")
        
        streakButton.tap()
        
        let yesterdayCell = app.cells[.FSCalendarView_Cell(date: Date().daysAgo(1))]
        yesterdayCell.tap()
        
        // TODO: Check if all elements in there like mood etc.
    }
}
