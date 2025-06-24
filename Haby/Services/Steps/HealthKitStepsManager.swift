
import HealthKit

class HealthKitStepsManager : StepsManaging {
    
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    func hasAskedForPermission() -> Bool {
        let status = healthStore.authorizationStatus(for: stepType)

        return status != .notDetermined
    }
    
    func requestPermission() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                } else {
                    print(success ? "✅ HealthKit access asked successfully" : "❌ HealthKit access not asked due to error")
                }
                continuation.resume()
            }
        }
    }
    
    func fetchStepsForToday() async -> Int {
        await withCheckedContinuation { continuation in
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, result, error in
                if let error = error {
                    print("HealthKit error: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }

                guard let quantity = result?.sumQuantity() else {
                    print("No step data available.")
                    continuation.resume(returning: 0)
                    return
                }

                let steps = quantity.doubleValue(for: .count())
                continuation.resume(returning: Int(steps))
            }

            healthStore.execute(query)
        }
    }
    
    func fetchStepsForWeek() async -> Int {
        await withCheckedContinuation { continuation in
            let calendar = Calendar.current
            let now = Date()
            guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
                continuation.resume(returning: 0)
                return
            }

            let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)
            
            let interval = DateComponents(day: 1)

            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startOfWeek,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                guard let statsCollection = results, error == nil else {
                    print("Error fetching weekly steps: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(returning: 0)
                    return
                }

                var totalSteps = 0

                statsCollection.enumerateStatistics(from: startOfWeek, to: now) { stats, _ in
                    let steps = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    totalSteps += Int(steps)
                }

                continuation.resume(returning: totalSteps)
            }

            healthStore.execute(query)
        }
    }


    
    func fetchMonthlyStepData() async -> [StepData] {
        await withCheckedContinuation { continuation in
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let calendar = Calendar.current
            let endDate = Date()
            let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!

            var interval = DateComponents()
            interval.day = 1

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: calendar.startOfDay(for: startDate),
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, _ in
                var result: [StepData] = []

                results?.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                    let steps = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    result.append(StepData(date: stat.startDate, steps: steps))
                }

                continuation.resume(returning: result.sorted(by: { $0.date < $1.date }))
            }

            healthStore.execute(query)
        }
    }
}
