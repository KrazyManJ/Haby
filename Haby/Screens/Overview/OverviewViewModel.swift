

import SwiftUI
import HealthKit

@Observable
class OverviewViewModel: ObservableObject {
    var state = OverviewViewState()
    
    private let healthStore = HKHealthStore()
    private let dataManaging: Injected<DataManaging> = .init()
    private let stepsManaging: Injected<StepsManaging> = .init()
    
    init() {
        state.moodRecords = dataManaging.wrappedValue.fetch()
    }
    
    func loadStepData() async {
        state.stepsToday = await stepsManaging.wrappedValue.fetchStepsForToday()
        state.monthlySteps =  await stepsManaging.wrappedValue.fetchMonthlyStepData()
    }
    
    func selectDate(date: Date?) {
        if let date = date {
            state.selectedDateData = SelectedDateData(
                date: date,
                mood: dataManaging.wrappedValue.getMoodRecordByDate(date: date)?.toModel().mood,
                habitRecords: dataManaging.wrappedValue.getRecordsByDate(date: date),
                habitsForDate: dataManaging.wrappedValue.getHabitsForDate(date: date).filter { date.nextDay > $0.creationDate }
            )
        }
        else {
            state.selectedDateData = nil
        }
    }
    
    internal func wasHabitRecorded(habit: HabitDefinition, date: Date) -> Bool {
        let habitsRecords: [HabitRecord] = dataManaging.wrappedValue.getRecordsByDate(date: date)
        return habitsRecords.contains{ r in r.habitDefinition.id == habit.id }
    }
    
    internal func hasCompletedHabit(habit: HabitDefinition, date: Date) -> Bool {
        let habitsRecords: [HabitRecord] = dataManaging.wrappedValue.getRecordsByDate(date: date)
        
        if let record = habitsRecords.first(where: { r in
            r.habitDefinition.id == habit.id
        }) {
            return record.isCompleted
        }
        return false
    }
    
    internal func hasAllHabitsInDay(date: Date) -> Bool {
        let habits = dataManaging.wrappedValue.getHabitsForDate(date: date)
        
        return habits
            .filter { date.nextDay > $0.creationDate }
            .allSatisfy { hasCompletedHabit(habit: $0, date: date) }
    }
    
    func loadCompletedDates() {
        state.completedDates.removeAll()
        dataManaging.wrappedValue.fetchDatesWithHabitRecords().forEach { date in
            if hasAllHabitsInDay(date: date) {
                state.completedDates.insert(date)
            }
        }
        state.streak = calculateStreak()
    }
    
    private func calculateStreak() -> Int {
        var streak = 0
        if state.completedDates.contains(Date().onlyDate) {
            streak += 1
        }
        
        var currentDate = Date().onlyDate.daysAgo(1)
        
        while state.completedDates.contains(currentDate) {
            streak += 1
            currentDate = currentDate.daysAgo(1)
        }
        
        return streak
    }
}
