
import SwiftUI
import HealthKit

@Observable
class DailyViewModel: ObservableObject {
    var state: DailyViewState = DailyViewState()
    
    @ObservationIgnored @Injected private var dataManaging: DataManaging
    @ObservationIgnored @Injected private var healthKitManager: HealthManaging
    @ObservationIgnored @Injected private var habitManager: HabitManaging
    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    
    var showHealthKitError: Bool = false
    
    var healthData: [AmountUnit: Double] = [:]

    // fix - data based on chosen values in popup
    func loadHealthDataForToday() async {
        async let steps = healthKitManager.fetchTodaySteps()
        async let calories = healthKitManager.fetchTodayCalories()
        async let distance = healthKitManager.fetchTodayDistance()
        async let workoutTime = healthKitManager.fetchTodayWorkoutTime()
        
        let fetchedSteps = await steps
        let fetchedCalories = await calories
        let fetchedDistance = await distance
        let fetchedWorkoutTime = await workoutTime
        
        healthData[.Steps] = fetchedSteps
        healthData[.Calories] = fetchedCalories
        healthData[.Kilometers] = fetchedDistance
        healthData[.ExerciseTime] = fetchedWorkoutTime
    }
    
    func askForNotificationPermission() {
        notificationManager.requestPermission() { _ in }
    }
    
    func syncHealthDataToHabits() {
        for habit in state.amountHabits {
            guard habit.isUsingHealthData,
                  let unit = habit.targetValueUnit,
                  let healthValue = healthData[unit] else { continue }
            
//            upsertHabitRecord(habit: habit, value: Float(healthValue))
            if let existing = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
                var updatedRecord = existing
                updatedRecord.value = Float(healthValue)
                dataManaging.upsert(model: updatedRecord)
            } else {
                let newRecord = HabitRecord(
                    id: UUID(),
                    date: Date().onlyDate,
                    value: Float(healthValue),
                    habitDefinition: habit,
                    data: .Amount(data: .init(date: Date().onlyDate, value: Float(healthValue)))
                )
                dataManaging.upsert(model: newRecord)
            }
        }
        
        state.habitRecords = dataManaging.getTodayRecords()
    }
    
    func updateMood(mood: Mood) {
        dataManaging.upsert(model: state.todayMoodData)
    }
    
    func getTodayMood() {
        if let todayMoodDataEntity = dataManaging.getMoodRecordByDate(date: Date().onlyDate) {
            state.todayMoodData = todayMoodDataEntity.toModel()
        }
    }
    
    func isTodayMoodSaved() -> Bool {
        let moodSavedFromDate = dataManaging.getMoodRecordByDate(date: Date().onlyDate)
        return moodSavedFromDate != nil
    }
    
    func getTodayHabits() {
        state.habits = dataManaging.getTimeHabitsForToday()
        state.habitRecords = dataManaging.getTodayRecords()
        state.amountHabits = dataManaging.getAmountHabitsForToday()
    }
    
    
    func checkHabit(habit: HabitDefinition) {
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let currentTimestamp = hour * 60 + minute
        
        
        
        if let record = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
            if let entity: HabitRecordEntity = dataManaging.fetchOneById(id: record.id) {
                dataManaging.delete(entity: entity)
            }
        }
        else {
            var recordData: HabitRecordData {
                if habit.data.type == .Deadline {
                    return .Deadline(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: currentTimestamp))
                } else {
                    return .OnTime(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: currentTimestamp))
                }
            }
            
            dataManaging.upsert(model: HabitRecord(
                date: Date().onlyDate,
                timestamp: currentTimestamp,
                habitDefinition: habit,
                data: recordData
            ))
            PhoneSessionManager.shared.syncAllHabitsToWatch()
        }

        getTodayHabits()
    }
    
    func addToAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let today = Date().onlyDate

        if var record = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
            switch record.data {
            case .Amount(var data):
                data.value += addedAmount
                record.data = .Amount(data: data)
                record.value = (record.value ?? 0) + addedAmount
                dataManaging.upsert(model: record)
            default:
                break
            }
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit,
                data: .Amount(data: .init(date: today, value: addedAmount))
            )
            dataManaging.upsert(model: newRecord)
            
            PhoneSessionManager.shared.syncAllHabitsToWatch()
        }

        getTodayHabits()
    }

}
