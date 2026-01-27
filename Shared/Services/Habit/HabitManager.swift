import Foundation

class HabitManager : HabitManaging {
    
    @Injected private var dataManager: DataManaging
    
    /// Returns true when there are all records for all habits for that day and each record is satisfied
    func hasAllHabitsInDay(day date: Date) -> Bool {
        let habits = dataManager.getHabitsForDate(date: date)
        let records = dataManager.getRecordsByDate(date: date)
        
        let eachHabitHasRecord = habits.allSatisfy { habit in
            records.contains { record in record.habitDefinition.id == habit.id}
        }
        
        guard eachHabitHasRecord else {
            return false
        }
        
        let eachRecordIsSatisfied = records.allSatisfy({ $0.isSatisfied })
        
        guard eachRecordIsSatisfied else {
            return false
        }
        
        return true
    }
    
    func getDatesWithAllSatisfiedHabits() -> [Date] {
        let dates = dataManager.fetchDatesWithHabitRecords()
        return dates.filter { hasAllHabitsInDay(day: $0) }
    }
    
    func calculateCurrentStreak() -> Int {
        let completedDates = getDatesWithAllSatisfiedHabits()
        
        var streak = 0
        
        if completedDates.contains(Date().onlyDate) {
            streak += 1
        }
        
        var currentDate = Date().onlyDate.daysAgo(1)
        
        while completedDates.contains(currentDate) {
            streak += 1
            currentDate = currentDate.daysAgo(1)
        }
        
        return streak
    }
}
