
import SwiftUI
import HealthKit

@Observable
class DailyViewModel {
    var state: DailyViewState = DailyViewState()
    
    @ObservationIgnored @Injected private var dataManaging: DataManaging
    @ObservationIgnored @Injected private var healthManager: HealthManaging
    @ObservationIgnored @Injected private var habitManager: HabitManaging
    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    @ObservationIgnored @Injected private var phoneSessionManager: PhoneSessionManaging
    
    var showHealthKitError: Bool = false
    
    var healthData: [AmountUnit: Double] = [:]
    
    
    func startListeningToHealthKit() {
        healthManager.stopListening()
        let requiredUnits = Set(state.amountHabits
            .filter { $0.isUsingHealthData }
            .compactMap { $0.targetValueUnit }
        )
            
        if requiredUnits.contains(.Steps) {
            healthManager.startObservingSteps { [weak self] val in
                Task { @MainActor in
                    print("live update: steps changed to \(val)")
                    self?.healthData[.Steps] = val
                    self?.syncHealthDataToHabits()
                }
            }
        }
        if requiredUnits.contains(.Calories) {
            healthManager.startObservingCalories { [weak self] val in
                Task { @MainActor in
                    print("live update: calories changed to \(val)")
                    self?.healthData[.Calories] = val
                    self?.syncHealthDataToHabits()
                }
            }
        }
        if requiredUnits.contains(.Kilometers) {
            healthManager.startObservingDistance { [weak self] val in
                Task { @MainActor in
                    print("live update: km changed to \(val)")
                    self?.healthData[.Kilometers] = val
                    self?.syncHealthDataToHabits()
                }
            }
        }
    }
    
    func requestMissingPermissions() async {
        let requiredUnits = Set(state.amountHabits
            .filter { $0.isUsingHealthData }
            .compactMap { $0.targetValueUnit }
        )
        
        for unit in requiredUnits {
            if healthManager.needsAuthorization(for: unit) {
                print("🆕 Requesting permission for \(unit)...")
                await healthManager.requestAuthorization(for: unit)
            }
        }
    }


    // fix - data based on chosen values in popup
    func loadHealthDataForToday() async {
        let requiredUnits = Set(state.amountHabits
            .filter { $0.isUsingHealthData }
            .compactMap { $0.targetValueUnit }
        )
        
        if requiredUnits.contains(.Steps) {
            let steps = await healthManager.fetchTodaySteps()
            healthData[.Steps] = steps
            print("🫀 DEBUG: Fetched Steps: \(steps)")
        }
        
        if requiredUnits.contains(.Calories) {
            let calories = await healthManager.fetchTodayCalories()
            healthData[.Calories] = calories
            print("🫀 DEBUG: Fetched calories: \(calories)")
        }
        
        if requiredUnits.contains(.Kilometers) {
            let dist = await healthManager.fetchTodayDistance()
            healthData[.Kilometers] = dist
            print("🫀 DEBUG: Fetched distance: \(dist)")

        }
        let queryDate = Date().onlyDate
            print("🗓️ DEBUG: Querying Database for Date: \(queryDate)")
        let records = dataManaging.getTodayRecords()
            print("🗄️ DEBUG: Database returned \(records.count) records")
            for r in records {
                print("   -> Found Record: \(r.value) for \(r.habitDefinition.name) at \(r.date)")
            }
    }
    
    func askForNotificationPermission() {
        notificationManager.requestPermission() { _ in }
    }
    
    func syncHealthDataToHabits() {
        var hasChanges = false
        
        for habit in state.amountHabits {
            guard habit.isUsingHealthData,
                  let unit = habit.targetValueUnit,
                  let healthValue = healthData[unit] else { continue }
            
            let newValue = Float(healthValue)
            
            if let index = state.habitRecords.firstIndex(where: { $0.habitDefinition.id == habit.id }) {
                if state.habitRecords[index].value != newValue {
                    print("🔄 Syncing \(habit.name): \(state.habitRecords[index].value ?? 0) -> \(newValue)")
                    state.habitRecords[index].value = newValue
                    state.habitRecords[index].data = .Amount(data: .init(date: Date().onlyDate, value: newValue))
                    
                    dataManaging.upsert(model: state.habitRecords[index])
                    hasChanges = true
                }
            } else {
                let newRecord = HabitRecord(
                    id: UUID(),
                    date: Date().onlyDate,
                    value: newValue,
                    habitDefinition: habit,
                    data: .Amount(data: .init(date: Date().onlyDate, value: newValue))
                )
                state.habitRecords.append(newRecord)
                dataManaging.upsert(model: newRecord)
                print("⚡️ Live Create (UI): \(habit.name) -> \(newValue)")
                hasChanges = true
            }
        }
        if hasChanges {
            let temp = state.habitRecords
            state.habitRecords = temp
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
        }
        phoneSessionManager.syncAllHabitsToWatch()
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
            
            phoneSessionManager.syncAllHabitsToWatch()
        }

        getTodayHabits()
    }

}
