import XCTest

final class Haby_Creation_UI_Tests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor
    func test_habit_creation_success() throws {
        
        let newHabitName = "My New Awesome Habit"
        
        let app = XCUIApplication()
        app.launch()
        
        let habitTabButton = app.tabBars.buttons[.MainTabView_HabitsTabButton]
        XCTAssertTrue(habitTabButton.waitForExistence(timeout: 5))
        habitTabButton.tap()
        
        let addEditHabit = app.navigationBars.buttons[.MainTabView_AddHabitToolbarItem]
        
        addEditHabit.tap()
        
        let nameInput = app.textFields[.AddEditHabitView_NameInput]
        nameInput.tap()
        nameInput.typeText(newHabitName)
        
        let saveButton = app.buttons[.AddEditHabitView_SaveButton]
        saveButton.tap()
        
        let text = app.staticTexts
            .matching(identifier: AccessibilityTag.HabitDefinitionRow_Element.rawValue)
            .matching(identifier: newHabitName)
            .firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5))
    }
}

