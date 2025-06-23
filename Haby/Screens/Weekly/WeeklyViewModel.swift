
import SwiftUI

@Observable
class WeeklyViewModel: ObservableObject {
    var state: WeeklyViewState = WeeklyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    func getWeekHabits() {
        state.amountHabits = dataManaging.wrappedValue.getAmountHabitsForWeek()
        //state.habitRecords = dataManaging.wrappedValue.getTodayRecords()
        state.habits = dataManaging.wrappedValue.getTimeHabitsForWeek()
    }
    
    func addToAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let today = Date().onlyDate
        let weekStart = Calendar.current.startOfWeek(for: today)
        
        // Find existing record for the same habit within the current week
        if var existingRecord = state.habitRecords.first(where: {
            $0.habitDefinition.id == habit.id &&
            Calendar.current.isDate($0.date, inSameWeekAs: today)
        }) {
            existingRecord.value = (existingRecord.value ?? 0) + addedAmount
            dataManaging.wrappedValue.upsert(model: existingRecord)
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit
            )
            dataManaging.wrappedValue.upsert(model: newRecord)
        }
        
        getWeekHabits()
        
    }
    
    // TODO fix
    func isHabitChecked(habit: HabitDefinition, on date: Date) -> Bool {
        state.habitRecords.contains {
            $0.habitDefinition.id == habit.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func setHabit(_ habit: HabitDefinition, checked: Bool, on date: Date) {
        if checked {
            // Add record
            if !isHabitChecked(habit: habit, on: date) {
                let record = HabitRecord(
                    id: UUID(),
                    date: date.onlyDate,
                    value: 1,
                    habitDefinition: habit
                )
                dataManaging.wrappedValue.upsert(model: record)
            }
        } else {
            // Remove record
            if let record = state.habitRecords.first(where: {
                $0.habitDefinition.id == habit.id &&
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }) {
                //dataManaging.wrappedValue.delete(model: record)
            }
        }

        getWeekHabits()
    }

}
