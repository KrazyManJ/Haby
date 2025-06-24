
import SwiftUI

@Observable
class WeeklyViewModel: ObservableObject {
    var state: WeeklyViewState = WeeklyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    var selectedDates: [UUID: Date] = [:]
    
    var healthKitManager: Injected<StepsManaging> = .init()
    
    var stepsThisWeek: Int = 0
    var isLoadingSteps: Bool = true
    var showHealthKitError: Bool = false
    
    func loadStepData() async {
        await fetchStepsThisWeek()
    }
    
    private func fetchStepsThisWeek() async {
        stepsThisWeek = await healthKitManager.wrappedValue.fetchStepsForWeek()
    }

    func syncHealthDataToHabits() {
        for habit in state.amountHabits {
            guard habit.isUsingHealthData,
                  habit.targetValueUnit == .Steps else { continue }

            let currentSteps = Float(stepsThisWeek)

            if let existing = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
                var updatedRecord = existing
                updatedRecord.value = currentSteps
                dataManaging.wrappedValue.upsert(model: updatedRecord)
            } else {
                let newRecord = HabitRecord(
                    id: UUID(),
                    date: Date().onlyDate,
                    value: currentSteps,
                    habitDefinition: habit
                )
                dataManaging.wrappedValue.upsert(model: newRecord)
            }
        }
        state.habitRecords = dataManaging.wrappedValue.getTodayRecords()
    }
    
    func getWeekHabits() {
        state.amountHabits = dataManaging.wrappedValue.getAmountHabitsForWeek()
        state.habitRecords = dataManaging.wrappedValue.getWeekRecords()
        state.habits = dataManaging.wrappedValue.getTimeHabitsForWeek()
    }
    
    func addToWeeklyAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let calendar = Calendar.current
        let today = Date().onlyDate
        
        if var record = state.habitRecords.first(where: {
            return $0.habitDefinition.id == habit.id &&
            calendar.isDate($0.date.onlyDate, inSameWeekAs: today)
        }) {
            record.value = (record.value ?? 0) + addedAmount
            dataManaging.wrappedValue.upsert(model: record)
            print("record updated")
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit
            )
            dataManaging.wrappedValue.upsert(model: newRecord)
            print("new record saved")
        }
        self.getWeekHabits()
    }

    func isHabitChecked(habit: HabitDefinition, on date: Date) -> Bool {
        state.habitRecords.contains {
            $0.habitDefinition.id == habit.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func setHabit(_ habit: HabitDefinition, checked: Bool, on date: Date) {
        if checked {
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
            print(dataManaging.wrappedValue.getWeekRecords().count)
            if let record = state.habitRecords.first(where: {
                $0.habitDefinition.id == habit.id &&
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }) {
                if let entity: HabitRecordEntity = dataManaging.wrappedValue.fetchOneById(id: record.id) {
                    
                    dataManaging.wrappedValue.delete(entity: entity)
                }
            }
            print(dataManaging.wrappedValue.getWeekRecords().count)
            print(
                state.habitRecords.first(where: {
                    $0.habitDefinition.id == habit.id &&
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                })
            )
        }

        getWeekHabits()
    }
    
    func totalWeeklyAmount(for habit: HabitDefinition, weekOf date: Date = Date()) -> Float {
        if habit.isUsingHealthData && habit.targetValueUnit == .Steps {
                return Float(stepsThisWeek)
            }

        let calendar = Calendar.current

        return state.habitRecords
            .filter {
                $0.habitDefinition.id == habit.id &&
                calendar.isDate($0.date, inSameWeekAs: date)
            }
            .reduce(0.0) { $0 + ($1.value ?? 0) }
    }


}
