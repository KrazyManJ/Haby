

import SwiftUI
import HealthKit

@Observable
class OverviewViewModel: ObservableObject {
    let state = OverviewViewState()
    
    private let healthStore = HKHealthStore()
    private let dataManaging: Injected<DataManaging> = .init()
    private let stepsManaging: Injected<StepsManaging> = .init()
    
    func loadStepData() async {
        state.stepsToday = await stepsManaging.wrappedValue.fetchStepsForToday()
        state.monthlySteps =  await stepsManaging.wrappedValue.fetchMonthlyStepData()
    }
    
    func loadCompletedDates() {
        dataManaging.wrappedValue.fetchDatesWithHabitRecords().forEach { date in
            let timeHabitsInDate: [HabitDefinition] = dataManaging.wrappedValue.getTimeHabitsForDate(date: date)
            let amountHabitsInDate: [HabitDefinition] = dataManaging.wrappedValue.getAmountHabitsForDate(date: date)
            let habitsRecords: [HabitRecord] = dataManaging.wrappedValue.getRecordsByDate(date: date)
            
            let allTimeHabitsRecorded = timeHabitsInDate.allSatisfy { habit in
                if let record = habitsRecords.first(where: { r in
                    r.date == date && r.habitDefinition.id == habit.id
                }) {
                    return habit.canBeCheckedInTimestamp(timestamp: record.timestamp!)
                }
                return false
            }
            print("time valid", allTimeHabitsRecorded)
            let allAmountHabitsRecorded = amountHabitsInDate.allSatisfy() { habit in
                if let record = habitsRecords.first(where: { r in
                    r.date == date && r.habitDefinition.id == habit.id
                }) {
                    print(habit.name, record.value, habit.targetValue, record.isCompleted)
                    return record.isCompleted
                }
                
                return false
            }
            print("valid", allAmountHabitsRecorded)
            if allTimeHabitsRecorded && allAmountHabitsRecorded {
                state.completedDates.insert(date)
            }
        }
    }
}

#Preview {
   // OverviewViewModel()
}
