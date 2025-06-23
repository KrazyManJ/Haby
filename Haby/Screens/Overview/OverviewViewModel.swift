

import SwiftUI
import HealthKit

@Observable
class OverviewViewModel: ObservableObject {
    var state = OverviewViewState()
    
    private let healthStore = HKHealthStore()
    private let dataManaging: Injected<DataManaging> = .init()
    private let stepsManaging: Injected<StepsManaging> = .init()
    
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
            
            let allTimeHabitsRecorded = timeHabitsInDate.allSatisfy { habit in
                if let record = habitsRecords.first(where: { r in
                    r.habitDefinition.id == habit.id
                }) {
                    return record.isCompleted
                }
                return false
            }
            let allAmountHabitsRecorded = amountHabitsInDate.allSatisfy() { habit in
                if let record = habitsRecords.first(where: { r in
                    r.habitDefinition.id == habit.id
                }) {
                    return record.isCompleted
                }
                
                return false
            }
            habitsRecords.forEach { print($0.isCompleted,$0.habitDefinition.name) }
            
            if allTimeHabitsRecorded && allAmountHabitsRecorded {
                state.completedDates.insert(date)
            }
        }
        state.streak = calculateStreak()
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date()) // today at 00:00
        
        while state.completedDates.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }
        
        return streak
    }
}

#Preview {
   // OverviewViewModel()
}
