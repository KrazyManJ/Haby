
import SwiftUI
import HealthKit

@Observable
class DailyViewModel: ObservableObject {
    var state: DailyViewState = DailyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    private let healthStore = HKHealthStore()
    var stepsToday: Double = 0
    
    func loadStepData() async {
        await fetchStepsToday()
    }
    
    private func fetchStepsToday() async {
       let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
       let startOfDay = Calendar.current.startOfDay(for: Date())

       let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

       let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
           guard let quantity = result?.sumQuantity() else { return }
           DispatchQueue.main.async {
               self.stepsToday = quantity.doubleValue(for: .count())
           }
       }

       healthStore.execute(query)
   }
    
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
            dataManaging.wrappedValue.upsert(model: HabitRecord(
                id: UUID(),
                date: Date().onlyDate,
                timestamp: currentTimestamp,
                habitDefinition: habit
            ))
        }

        getTodayHabits()
    }
}
