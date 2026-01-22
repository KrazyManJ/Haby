
import SwiftUI
import HealthKit

@Observable
class DailyViewModel: ObservableObject {
    var state: DailyViewState = DailyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    var healthKitManager: Injected<HealthManaging> = .init()
    
    var showHealthKitError: Bool = false
    
    var healthData: [AmountUnit: Double] = [:]

    // fix - data based on chosen values in popup
    func loadHealthDataForToday() async {
        async let steps = healthKitManager.wrappedValue.fetchTodaySteps()
        async let calories = healthKitManager.wrappedValue.fetchTodayCalories()
        async let distance = healthKitManager.wrappedValue.fetchTodayDistance()
        async let workoutTime = healthKitManager.wrappedValue.fetchTodayWorkoutTime()
        
        let fetchedSteps = await steps
        let fetchedCalories = await calories
        let fetchedDistance = await distance
        let fetchedWorkoutTime = await workoutTime
        
        healthData[.Steps] = fetchedSteps
        healthData[.Calories] = fetchedCalories
        healthData[.Kilometers] = fetchedDistance
        healthData[.ExerciseTime] = fetchedWorkoutTime
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
                dataManaging.wrappedValue.upsert(model: updatedRecord)
            } else {
                let newRecord = HabitRecord(
                    id: UUID(),
                    date: Date().onlyDate,
                    value: Float(healthValue),
                    habitDefinition: habit,
                    data: .Amount(data: .init(value: Float(healthValue)))
                )
                dataManaging.wrappedValue.upsert(model: newRecord)
            }
        }
        
        state.habitRecords = dataManaging.wrappedValue.getTodayRecords()
    }
    
//    func loadStepData() async {
//        await fetchStepsToday()
//    }
//    
//    private func fetchStepsToday() async {
//        stepsToday = await Int(healthKitManager.wrappedValue.fetchTodaySteps())
//    }
//
//    func syncHealthDataToHabits() {
//        for habit in state.amountHabits {
//            guard habit.isUsingHealthData,
//                  habit.targetValueUnit == .Steps else { continue }
//
//            let currentSteps = Float(stepsToday)
//
//            if let existing = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
//                var updatedRecord = existing
//                updatedRecord.value = currentSteps
//                dataManaging.wrappedValue.upsert(model: updatedRecord)
//            } else {
//                let newRecord = HabitRecord(
//                    id: UUID(),
//                    date: Date().onlyDate,
//                    value: currentSteps,
//                    habitDefinition: habit
//                )
//                dataManaging.wrappedValue.upsert(model: newRecord)
//            }
//        }
//        state.habitRecords = dataManaging.wrappedValue.getTodayRecords()
//    }


    
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
        state.habits = dataManaging.wrappedValue.getTimeHabitsForToday()
        state.habitRecords = dataManaging.wrappedValue.getTodayRecords()
        state.amountHabits = dataManaging.wrappedValue.getAmountHabitsForToday()
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
            var recordData: HabitRecordData {
                if habit.data.type == .Deadline {
                    return .Deadline(data: .init(minutesOfCompletionInFrequency: currentTimestamp))
                } else {
                    return .OnTime(data: .init(minutesOfCompletionInFrequency: currentTimestamp))
                }
            }
            
            dataManaging.wrappedValue.upsert(model: HabitRecord(
                date: Date().onlyDate,
                timestamp: currentTimestamp,
                habitDefinition: habit,
                data: recordData
            ))
        }

        getTodayHabits()
    }
    
    func addToAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let today = Date().onlyDate

        if var record = state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
            record.value = (record.value ?? 0) + addedAmount
            dataManaging.wrappedValue.upsert(model: record)
            
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit,
                data: .Amount(data: .init(value: addedAmount))
            )
            dataManaging.wrappedValue.upsert(model: newRecord)
        }

        getTodayHabits()
    }

}
