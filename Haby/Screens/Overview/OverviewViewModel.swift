

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
    
    func loadCompletedDates() {
        state.completedDates.removeAll()
        dataManaging.wrappedValue.fetchDatesWithHabitRecords().forEach { date in
            let timeHabitsInDate: [HabitDefinition] = dataManaging.wrappedValue.getTimeHabitsForDate(date: date)
            let amountHabitsInDate: [HabitDefinition] = dataManaging.wrappedValue.getAmountHabitsForDate(date: date)
            let habitsRecords: [HabitRecord] = dataManaging.wrappedValue.getRecordsByDate(date: date)
            
            let allTimeHabitsRecorded = timeHabitsInDate
                .filter({ date.nextDay > $0.creationDate })
                .allSatisfy { habit in
                if let record = habitsRecords.first(where: { r in
                    r.habitDefinition.id == habit.id
                }) {
                    return record.isCompleted
                }
                return false
            }
            let allAmountHabitsRecorded = amountHabitsInDate
                .filter({ date.nextDay > $0.creationDate })
                .allSatisfy() { habit in
                if let record = habitsRecords.first(where: { r in
                    r.habitDefinition.id == habit.id
                }) {
                    return record.isCompleted
                }
                
                return false
            }
            
            if allTimeHabitsRecorded && allAmountHabitsRecorded {
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
