
import SwiftUI

@Observable
class DailyViewModel: ObservableObject {
    var state: DailyViewState = DailyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    func updateMood(mood: Mood) {
        dataManaging.wrappedValue.upsert(model: state.todayMoodData)
    }
    
    func getTodayMood() {
        if let todayMoodDataEntity = dataManaging.wrappedValue.getMoodRecordByDate(date: Date().onlyDate) {
            state.todayMoodData = todayMoodDataEntity.toModel()
        }
    }
    
    func isTodayMoodSaved() -> Bool {
        let moodSavedFromDate = dataManaging.wrappedValue.getMoodRecordByDate(date: Date().onlyDate)
        return moodSavedFromDate != nil
    }
    
    func getTodayHabits() {
        state.habits = dataManaging.wrappedValue.getHabitsForToday()
        state.habitRecords = dataManaging.wrappedValue.getTodayRecords()
    }
    
    func checkHabit(habit: HabitDefinition) {
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let currentTimestamp = hour * 60 + minute
        
        if let record = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
            if let entity: HabitRecordEntity = dataManaging.wrappedValue.fetchOneById(id: record.id) {
                dataManaging.wrappedValue.delete(entity: entity)
            }
        }
        else {
            dataManaging.wrappedValue.upsert(model: HabitRecord(
                id: UUID(),
                date: Date().onlyDate,
                timestamp: currentTimestamp,
                habitDefinition: habit
            ))
        }

        getTodayHabits()
    }
}
