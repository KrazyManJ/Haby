
import SwiftUI

@Observable
class WeeklyViewModel: ObservableObject {
    var state: WeeklyViewState = WeeklyViewState()
    
    @ObservationIgnored @Injected var dataManaging: DataManaging
    @ObservationIgnored @Injected var healthManager: HealthManaging
    
    var healthData: [AmountUnit: Double] = [:]
//    var stepsThisWeek: Int = 0
//    var isLoadingSteps: Bool = false
//    var showHealthKitError: Bool = false
    
//    func loadStepData() async {
//        await fetchStepsThisWeek()
//    }
//    
//    private func fetchStepsThisWeek() async {
//        stepsThisWeek = await Int(healthKitManager.fetchWeekSteps())
//    }
    
    func startListeningToHealthKit() {
        healthManager.stopListening()
        let requiredUnits = Set(state.amountHabits
            .filter { $0.isUsingHealthData }
            .compactMap { $0.targetValueUnit }
        )
            
        if requiredUnits.contains(.Steps) {
            healthManager.startObservingSteps { [weak self] in
                Task {
                    guard let self else { return }
                    let steps = await self.healthManager.fetchWeekSteps()
                    self.healthData[.Steps] = steps
                    self.syncHealthDataToHabits()
                }
            }
        }
        if requiredUnits.contains(.Calories) {
            healthManager.startObservingCalories { [weak self] in
                Task {
                    guard let self else { return }
                    let steps = await self.healthManager.fetchWeekCalories()
                    self.healthData[.Calories] = steps
                    self.syncHealthDataToHabits()
                }
            }
        }
        if requiredUnits.contains(.Kilometers) {
            healthManager.startObservingDistance { [weak self] in
                Task { @MainActor in
                    guard let self else { return }
                    let steps = await self.healthManager.fetchWeekDistance()
                    self.healthData[.Kilometers] = steps
                    self.syncHealthDataToHabits()
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
//                print("🆕 Requesting permission for \(unit)...")
                await healthManager.requestAuthorization(for: unit)
            }
        }
    }


    func loadHealthDataForThisWeek() async {
        let requiredUnits = Set(state.amountHabits
            .filter { $0.isUsingHealthData }
            .compactMap { $0.targetValueUnit }
        )
        
        if requiredUnits.contains(.Steps) {
            let steps = await healthManager.fetchWeekSteps()
            healthData[.Steps] = steps
//            print("🫀 DEBUG: Fetched Steps: \(steps)")
        }
        
        if requiredUnits.contains(.Calories) {
            let calories = await healthManager.fetchWeekCalories()
            healthData[.Calories] = calories
//            print("🫀 DEBUG: Fetched calories: \(calories)")
        }
        
        if requiredUnits.contains(.Kilometers) {
            let dist = await healthManager.fetchWeekDistance()
            healthData[.Kilometers] = dist
//            print("🫀 DEBUG: Fetched distance: \(dist)")

        }
        let queryDate = Date().onlyDate
//            print("🗓️ DEBUG: Querying Database for Date: \(queryDate)")
        let records = dataManaging.getWeekRecords()
        //    print("🗄️ DEBUG: Database returned \(records.count) records")
            for r in records {
          //      print("   -> Found Record: \(r.value) for \(r.habitDefinition.name) at \(r.date)")
            }
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
               //     print("🔄 Syncing \(habit.name): \(state.habitRecords[index].value ?? 0) -> \(newValue)")
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
               // print("⚡️ Live Create (UI): \(habit.name) -> \(newValue)")
                hasChanges = true
            }
        }
        if hasChanges {
            let temp = state.habitRecords
            state.habitRecords = temp
        }
        state.habitRecords = dataManaging.getWeekRecords()
    }
    
    /*
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
    */
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
//        if habit.isUsingHealthData && habit.targetValueUnit == .Steps {
//                return Float(stepsThisWeek)
//            }

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
//            await loadStepData()
            syncHealthDataToHabits()
        }
    }
}
