import XCTest
@testable import Haby

final class HabitManagerTests: XCTestCase {

    var habitManager: HabitManager!
    var dataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        
        // 1. Create In-Memory Data Manager
        dataManager = CoreDataManager(inMemory: true)
        
        // 2. Register it in DIContainer (Overwriting real app logic)
        DIContainer.shared.register(DataManaging.self) {
            return self.dataManager
        }
        
        // 3. Resolve the Service under test
        habitManager = HabitManager()
    }

    override func tearDown() {
        // 1. Clear the singleton so the next test doesn't inherit your mock
        DIContainer.shared.reset()
        
        habitManager = nil
        dataManager = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_CalculateStreak_WithBrokenHabit_ReturnsZero() {
        // GIVEN: Default mock data includes "Studying" habit which has NO records.
        insertDefaultMockData()
        
        // WHEN
        let streak = habitManager.calculateCurrentStreak()
        
        // THEN
        XCTAssertEqual(streak, 0, "Streak should be 0 because 'Studying' habit exists but has no records.")
    }
    
    func test_HasAllHabitsInDay_WhenOneRecordUnsatisfied_ReturnsFalse() {
        // GIVEN: A habit with a target of 10,000 steps
        let habit = HabitDefinition(
            name: "Steps",
            icon: "shoe",
            category: "Health",
            type: .Amount,        // Required (deprecated)
            frequency: .Daily,    // Required (deprecated)
            targetValue: 10000,   // Required (deprecated)
            targetValueUnit: .Steps,
            data: .Amount(data: .init(frequency: .Daily, amount: 10000, unit: .Steps))
        )
        dataManager.upsert(model: habit)
        
        // And a record for TODAY that only has 5,000 steps (Unsatisfied)
        let record = HabitRecord(
            date: Date().onlyDate, // ✅ ADDED (deprecated)
            value: 5000,           // ✅ ADDED (deprecated)
            habitDefinition: habit,
            data: .Amount(data: .init(date: Date().onlyDate, value: 5000))
        )
        dataManager.upsert(model: record)
        
        // WHEN
        let result = habitManager.hasAllHabitsInDay(day: Date().onlyDate)
        
        // THEN
        XCTAssertFalse(result, "Should return false because record value (5000) < target (10000).")
    }
    
    func test_HasAllHabitsInDay_WhenRecordMissing_ReturnsFalse() {
        // GIVEN: Two habits exist
        let h1 = HabitDefinition(
            name: "A", icon: "", category: "",
            type: .OnTime, frequency: .Daily,
            data: .OnTime(data: .init(frequency: .Daily, minutesOfCompletionInFrequency: 10))
        )
        let h2 = HabitDefinition(
            name: "B", icon: "", category: "",
            type: .OnTime, frequency: .Daily,
            data: .OnTime(data: .init(frequency: .Daily, minutesOfCompletionInFrequency: 10))
        )
        
        dataManager.upsert(model: h1)
        dataManager.upsert(model: h2)
        
        // But we only create a record for ONE of them
        let r1 = HabitRecord(
            date: Date().onlyDate, // ✅ ADDED (deprecated)
            habitDefinition: h1,
            data: .OnTime(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: 10))
        )
        dataManager.upsert(model: r1)
        
        // WHEN
        let result = habitManager.hasAllHabitsInDay(day: Date().onlyDate)
        
        // THEN
        XCTAssertFalse(result, "Should return false because habit 'B' has no record for today.")
    }
}

// MARK: - Test Helpers
extension HabitManagerTests {
    
    func removeHabit(named name: String) {
        let habits: [HabitDefinitionEntity] = dataManager.fetch()
        if let entityToDelete = habits.first(where: { $0.name == name }) {
            dataManager.delete(entity: entityToDelete)
        }
    }

    func insertDefaultMockData() {
        let createdAt = Date().onlyDate.daysAgo(50)
        
        // 1. Define Habits
        let yoga = HabitDefinition(
             name: "Yoga",
             icon: "figure.yoga",
             creationDate: createdAt,
             category: "Health",
             type: .Deadline,
             frequency: .Daily,
             targetTimestamp: 60 * 17,
             data: .Deadline(data: .init(frequency: .Daily, minutesOfCompletionInFrequency: 60 * 17))
         )
        
        // ... (Other habits omitted for brevity, add them if needed)
        
        let habits = [yoga]
        
        for habit in habits {
            dataManager.upsert(model: habit)
        }
        
        // 2. Insert Records
        let validDaysOffsets = [Int](1...8) + [Int](12...16) + [18] + [Int](22...48) + [50]
        let today = Date().onlyDate

        for habit in habits {
            for offset in validDaysOffsets {
                let recordDate = today.daysAgo(offset)
                
                let recordData: HabitRecordData = .Deadline(data: .init(
                    date: recordDate,
                    minutesOfCompletionInFrequency: 60 * 16 // Satisfied
                ))
                
                let record = HabitRecord(
                    date: recordDate, // ✅ ADDED (deprecated)
                    timestamp: 60 * 16, // ✅ ADDED (deprecated) - optional but good for completeness
                    habitDefinition: habit,
                    data: recordData
                )
                
                dataManager.upsert(model: record)
            }
        }
        
        // 3. Add the "Streak Breaker"
        let studying = HabitDefinition(
            name: "Studying",
            icon: "book",
            creationDate: Date().onlyDate.daysAgo(30),
            category: "Wellbeing",
            type: .Amount,
            frequency: .Daily,
            targetValue: 90,
            targetValueUnit: .Minutes,
            data: .Amount(data: .init(frequency: .Daily, amount: 90, unit: .Minutes))
        )
        dataManager.upsert(model: studying)
    }
}
