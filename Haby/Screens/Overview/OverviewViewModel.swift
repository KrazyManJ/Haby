

import SwiftUI
import HealthKit

@Observable
class OverviewViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    private let dataManaging: Injected<DataManaging>
        
//    var distanceToday: Double = 0.0
//    var monthlyDistances: [DistanceData] = []
    
    var stepsToday: Double = 0
    var monthlySteps: [StepData] = []
    var completedDates: Set<Date> = Set()
    
    init() {
        dataManaging = .init()
        requestAuthorization()
    }

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                Task {
                    await self.loadStepData()
                }
            }
        }
    }
    
    func loadStepData() async {
        await fetchStepsToday()
        await fetchMonthlyStepData()
    }
    
    func loadCompletedDates() {
        dataManaging.wrappedValue.fetchDatesWithHabitRecords().forEach { date in
            let habitsInDate: [HabitDefinition] = dataManaging.wrappedValue.getHabitsForDate(date: date)
            let habitsRecords: [HabitRecord] = dataManaging.wrappedValue.getRecordsByDate(date: date)
            
            for habit in habitsInDate {
                guard let record = habitsRecords.first(where: { r in
                    r.date == date && r.habitDefinition.id == habit.id
                }) else {
                    break
                }
                
                if habit.canBeCheckedInTimestamp(timestamp: record.timestamp!) {
                    completedDates.insert(date)
                }
            }
        }
    }
    
//    func loadDistance() {
//        fetchDistanceToday { [weak self] km in
//            DispatchQueue.main.async {
//                self?.distanceToday = km
//            }
//        }
//    }
//    
//    func loadDistanceData() {
//           fetchMonthlyDistanceData { data in
//               self.monthlyDistances = data
//           }
//       }
    
    // move to dailyviewmodel
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
    
    private func fetchMonthlyStepData() async {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!

        var interval = DateComponents()
        interval.day = 1

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: calendar.startOfDay(for: startDate), intervalComponents: interval)

        query.initialResultsHandler = { _, results, _ in
            var result: [StepData] = []
            results?.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                let steps = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                result.append(StepData(date: stat.startDate, steps: steps))
            }

            DispatchQueue.main.async {
                self.monthlySteps = result.sorted(by: { $0.date < $1.date })
            }
        }
        healthStore.execute(query)
    }
    
//    func fetchDistanceToday(completion: @escaping (Double) -> Void) {
//        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
//        let startOfDay = Calendar.current.startOfDay(for: Date())
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
//
//        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
//            guard let quantity = result?.sumQuantity() else {
//                completion(0.0)
//                return
//            }
//            let meters = quantity.doubleValue(for: .meter())
//            let kilometers = meters / 1000.0
//            completion(kilometers)
//        }
//        healthStore.execute(query)
//    }
//    
//    func fetchMonthlyDistanceData(completion: @escaping ([DistanceData]) -> Void) {
//            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
//            let calendar = Calendar.current
//            let endDate = Date()
//            let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
//
//            var interval = DateComponents()
//            interval.day = 1
//
//            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//            let query = HKStatisticsCollectionQuery(
//                quantityType: distanceType,
//                quantitySamplePredicate: predicate,
//                options: .cumulativeSum,
//                anchorDate: calendar.startOfDay(for: startDate),
//                intervalComponents: interval
//            )
//
//            query.initialResultsHandler = { _, results, _ in
//                var distances: [DistanceData] = []
//                results?.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
//                    let meters = stat.sumQuantity()?.doubleValue(for: .meter()) ?? 0
//                    let km = meters / 1000
//                    distances.append(DistanceData(date: stat.startDate, kilometers: km))
//                }
//
//                DispatchQueue.main.async {
//                    completion(distances)
//                }
//            }
//            healthStore.execute(query)
//        }
}

#Preview {
   // OverviewViewModel()
}
