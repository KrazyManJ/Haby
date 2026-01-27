
import SwiftUI

@Observable
class WeeklyViewModel: ObservableObject {
    var state: WeeklyViewState = WeeklyViewState()
    
    @ObservationIgnored @Injected var dataManaging: DataManaging
    @ObservationIgnored @Injected var healthKitManager: HealthManaging
    
    var stepsThisWeek: Int = 0
    var isLoadingSteps: Bool = false
    var showHealthKitError: Bool = false
    
    func loadStepData() async {
        await fetchStepsThisWeek()
    }
    
    private func fetchStepsThisWeek() async {
        stepsThisWeek = await Int(healthKitManager.fetchWeekSteps())
    }

    func syncHealthDataToHabits() {
        for habit in state.amountHabits {
            guard habit.isUsingHealthData,
                  habit.targetValueUnit == .Steps else { continue }

            let currentSteps = Float(stepsThisWeek)

            if let existing = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
                var updatedRecord = existing
                updatedRecord.value = currentSteps
                dataManaging.upsert(model: updatedRecord)
            } else {
                let newRecord = HabitRecord(
                    id: UUID(),
                    date: Date().onlyDate,
                    value: currentSteps,
                    habitDefinition: habit,
                    data: .Amount(data: .init(date: Date().onlyDate, value: currentSteps))
                )
                dataManaging.upsert(model: newRecord)
            }
        }
        state.habitRecords = dataManaging.getWeekRecords()
    }
    
    func getWeekHabits() {
        state.amountHabits = dataManaging.getAmountHabitsForWeek()
        state.habitRecords = dataManaging.getWeekRecords()
        state.habits = dataManaging.getTimeHabitsForWeek()
    }
    
    func addToWeeklyAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let calendar = Calendar.current
        let today = Date().onlyDate
        
        if var record = state.habitRecords.first(where: {
            return $0.habitDefinition.id == habit.id &&
            calendar.isDate($0.data.details.date.onlyDate, inSameWeekAs: today)
        }) {
            record.value = (record.value ?? 0) + addedAmount
            dataManaging.upsert(model: record)
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit,
                data: .Amount(data: .init(date: today, value: addedAmount))
            )
            dataManaging.upsert(model: newRecord)
        }
        self.getWeekHabits()
    }

    func isHabitChecked(habit: HabitDefinition, on date: Date) -> Bool {
        return state.habitRecords.contains { record in
            record.habitDefinition.id == habit.id &&
            Calendar.currentWithMondayAsSWeekStartDay.isDate(record.data.details.date, inSameDayAs: date)
        }
    }

    func setHabit(_ habit: HabitDefinition, checked: Bool, on date: Date) {
        if checked {
            var data: HabitRecordData {
                return switch habit.data.type {
                case .OnTime: .OnTime(data: .init(date: date, minutesOfCompletionInFrequency: date.minutesFromStartOfWeek()))
                case .Deadline: .Deadline(data: .init(date: date, minutesOfCompletionInFrequency: date.minutesFromStartOfWeek()))
                case .Amount: fatalError("Method called on amount habit")
                }
            }
            
            if !isHabitChecked(habit: habit, on: date) {
                let record = HabitRecord(
                    date: date.onlyDate,
                    value: 1,
                    habitDefinition: habit,
                    data: data
                )
                dataManaging.upsert(model: record)
            }
        } else {
            if let record = state.habitRecords.first(where: {
                $0.habitDefinition.id == habit.id &&
                Calendar.currentWithMondayAsSWeekStartDay.isDate($0.data.details.date, inSameDayAs: date)
            }) {
                if let entity: HabitRecordEntity = dataManaging.fetchOneById(id: record.id) {
                    
                    dataManaging.delete(entity: entity)
                }
            }
        }

        getWeekHabits()
    }
    
    func totalWeeklyAmount(for habit: HabitDefinition, weekOf date: Date = Date()) -> Float {
        if habit.isUsingHealthData && habit.targetValueUnit == .Steps {
                return Float(stepsThisWeek)
            }

        let calendar = Calendar.currentWithMondayAsSWeekStartDay

        return state.habitRecords
            .filter {
                $0.habitDefinition.id == habit.id &&
                calendar.isDate($0.data.details.date, inSameWeekAs: date)
            }
            .reduce(0.0) { $0 + ($1.value ?? 0) }
    }

    func refreshData() {
        getWeekHabits()
        Task {
            await loadStepData()
            syncHealthDataToHabits()
        }
    }
}
