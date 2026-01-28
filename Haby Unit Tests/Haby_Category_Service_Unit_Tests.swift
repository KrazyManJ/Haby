import XCTest
@testable import Haby

final class CategoryManagerTests: XCTestCase {
    
    var sut: CategoryManager! // "System Under Test"
    var testDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // 1. Create a temporary in-memory UserDefaults for this test
        // This prevents overwriting your real app data
        testDefaults = UserDefaults(suiteName: #file)
        testDefaults.removePersistentDomain(forName: #file)
        
        // 2. Initialize the manager with the test defaults
        sut = CategoryManager(defaults: testDefaults)
    }
    
    override func tearDown() {
        // Clean up after every test
        testDefaults.removePersistentDomain(forName: #file)
        sut = nil
        testDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Tests
    
    func test_fetchCategories_whenEmpty_returnsDefaultCategories() {
        // Given: Storage is empty
        
        // When
        let categories = sut.fetchCategories()
        
        // Then
        // Assuming HabitCategory has 3 items based on the stub above
        XCTAssertEqual(categories.count, 4)
        XCTAssertTrue(categories.contains("Health"))
    }
    
    func test_fetchCategories_whenDataExists_returnsSavedCategories() {
        // Given: We simulate previously saved data
        let savedData = ["Fitness", "Reading"]
        testDefaults.set(savedData, forKey: "UserHabitCategories")
        
        // When
        let categories = sut.fetchCategories()
        
        // Then
        XCTAssertEqual(categories, ["Fitness", "Reading"])
    }
    
    // MARK: - Add Tests
    
    func test_addCategory_validInput_appendsAndSorts() {
        // Given
        // Current defaults: ["Health", "Hobby", "Work"] (Alphabetical)
        
        // When: We add "Apple" (should go to the start) and "Zoo" (should go to the end)
        sut.addCategory("Zoo")
        sut.addCategory("Apple")
        
        // Then
        let current = sut.fetchCategories()
        XCTAssertTrue(current.contains("Zoo"))
        XCTAssertTrue(current.contains("Apple"))
        
        // Check sorting (Apple should be first)
        XCTAssertEqual(current.first, "Apple")
        XCTAssertEqual(current.last, "Zoo")
    }
    
    func test_addCategory_duplicateInput_doesNotAdd() {
        // Given
        sut.addCategory("NewHabit")
        let countBefore = sut.fetchCategories().count
        
        // When: Try to add the exact same string again
        sut.addCategory("NewHabit")
        
        // Then
        let countAfter = sut.fetchCategories().count
        XCTAssertEqual(countBefore, countAfter, "Should not add duplicate categories")
    }
    
    func test_addCategory_whitespaceInput_isIgnored() {
        // Given
        let countBefore = sut.fetchCategories().count
        
        // When: Add string with only spaces or newlines
        sut.addCategory("   ")
        sut.addCategory("\n")
        
        // Then
        let countAfter = sut.fetchCategories().count
        XCTAssertEqual(countBefore, countAfter, "Should not add empty or whitespace-only strings")
    }
    
    func test_addCategory_untrimmedInput_trimsAndAdds() {
        // Given
        
        // When: Add a category with extra spaces around it
        sut.addCategory("  Messy Habit  ")
        
        // Then
        let current = sut.fetchCategories()
        XCTAssertTrue(current.contains("Messy Habit"))
        XCTAssertFalse(current.contains("  Messy Habit  "), "Should store the trimmed version")
    }
}
