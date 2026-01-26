
import HealthKit

class HealthManager: HealthManaging {
    
    private let healthStore = HKHealthStore()
    
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let workoutTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    func hasAskedForPermission() -> Bool {
        // use this to show "connect to health" onboarding button
        // check for one type to see if the prompt was ever shown
        // if connected but 0 results, show "no data available" in UI
        // .notDetermined - user was not asked yet
        // .sharingAuthorized, .sharingDenied - prompt has appeared
        
        // requestPermission function requests all types -> we can check only one here
        let status = healthStore.authorizationStatus(for: stepType)
        return status != .notDetermined
    }
    
    func requestPermission() async {
            guard HKHealthStore.isHealthDataAvailable() else { return }
            
            let types: Set = [stepType, activeEnergyType, workoutTimeType, distanceType]
            
            do {
                try await healthStore.requestAuthorization(toShare: [], read: types)
                print("HealthKit request presented")
            } catch {
                print("Error requesting HealthKit: \(error.localizedDescription)")
            }
        }
    
    // returns single value for time range (day, week, month)
    func fetchStatistics(
        type: HKQuantityType,
        unit: HKUnit,
        startDate: Date,
        endDate: Date = Date()
    ) async -> Double {
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                
                guard let quantity = result?.sumQuantity(), error == nil else {
                    print("Error or no data: \(error?.localizedDescription ?? "Unknown")")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                if quantity.is(compatibleWith: unit) {
                        let value = quantity.doubleValue(for: unit)
                        continuation.resume(returning: value)
                    } else {
                        print("❌ Unit Mismatch! Data is in \(quantity) but requested \(unit.unitString)")
                        continuation.resume(returning: 0.0)
                    }
            }
            
            healthStore.execute(query)
        }
    }
    
    // returns array for time range - for graphs
    func fetchHistoricalData(
        type: HKQuantityType,
        unit: HKUnit,
        interval: DateComponents,
        startDate: Date,
        endDate: Date = Date()
    ) async -> [HealthDataPoint] {
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, results, _ in
                var dataPoints: [HealthDataPoint] = []
                
                results?.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                    let value = stat.sumQuantity()?.doubleValue(for: unit) ?? 0
                    dataPoints.append(HealthDataPoint(date: stat.startDate, value: value))
                }
                
                continuation.resume(returning: dataPoints)
            }
            healthStore.execute(query)
        }
    }
}

extension HealthManager {
    
    // todo make sure week starts on monday
    internal func getStartOf(component: Calendar.Component) -> Date {
        let calendar = Calendar.current
        let componentsToUse: Set<Calendar.Component> = component == .weekOfYear
        ? [.yearForWeekOfYear, .weekOfYear]
        : [.year, .month, .day]
        
        return calendar.date(from: calendar.dateComponents(componentsToUse, from: Date())) ?? Date()
    }
    
    
    // steps - daily + weekly view
    func fetchTodaySteps() async -> Double {
        return await fetchStatistics(
            type: stepType,
            unit: .count(),
            startDate: Calendar.current.startOfDay(for: Date())
        )
    }
    
    func fetchWeekSteps() async -> Double {
        return await fetchStatistics(
            type: stepType,
            unit: .count(),
            startDate: getStartOf(component: .weekOfYear),
            endDate: .now
        )
    }
    
    // steps - graph
    func fetchCurrentWeekStepData() async -> [HealthDataPoint] {
        var interval = DateComponents()
        interval.day = 1
        return await fetchHistoricalData(
            type: stepType,
            unit: .count(),
            interval: interval,
            startDate: getStartOf(component: .weekOfYear)
        )
    }
    
    func fetchCurrentMonthStepData() async -> [HealthDataPoint] {
        var interval = DateComponents()
        interval.day = 1
        return await fetchHistoricalData(
            type: stepType,
            unit: .count(),
            interval: interval,
            startDate: getStartOf(component: .month)
        )
    }
    
    // distance - daily + weekly view
    func fetchTodayDistance() async -> Double {
        return await fetchStatistics(
            type: distanceType,
            unit: .count(),
            startDate: Calendar.current.startOfDay(for: Date())
        )
    }
    
    func fetchWeekDistance() async -> Double {
        return await fetchStatistics(
            type: distanceType,
            unit: .count(),
            startDate: getStartOf(component: .weekOfYear),
            endDate: .now
        )
    }
    
    // distance - graph
    
    func fetchCurrentMonthDistanceData() async -> [HealthDataPoint] {
        var interval = DateComponents()
        interval.day = 1
        return await fetchHistoricalData(
            type: distanceType,
            unit: .count(),
            interval: interval,
            startDate: getStartOf(component: .month)
        )
    }
    
    // workout - daily + weekly view
    func fetchTodayWorkoutTime() async -> Double {
        return await fetchStatistics(
            type: workoutTimeType,
            unit: .count(),
            startDate: Calendar.current.startOfDay(for: Date())
        )
    }
    
    func fetchWeekWorkoutTime() async -> Double {
        return await fetchStatistics(
            type: workoutTimeType,
            unit: .count(),
            startDate: getStartOf(component: .weekOfYear),
            endDate: .now
        )
    }
    
    // workout - graph
    
    func fetchCurrentMonthWorkoutTimeData() async -> [HealthDataPoint] {
        var interval = DateComponents()
        interval.day = 1
        return await fetchHistoricalData(
            type: workoutTimeType,
            unit: .count(),
            interval: interval,
            startDate: getStartOf(component: .month)
        )
    }
    
    // calories - daily + weekly view
    func fetchTodayCalories() async -> Double {
        return await fetchStatistics(
            type: activeEnergyType,
            unit: .kilocalorie(),
            startDate: Calendar.current.startOfDay(for: Date())
        )
    }
    
    func fetchWeekCalories() async -> Double {
        return await fetchStatistics(
            type: activeEnergyType,
            unit: .kilocalorie(),
            startDate: getStartOf(component: .weekOfYear),
            endDate: .now
        )
    }
    
    // calories - graph
    func fetchCurrentWeekCalorieData() async -> [HealthDataPoint] {
        var interval = DateComponents()
        interval.day = 1
        return await fetchHistoricalData(
            type: activeEnergyType,
            unit: .kilocalorie(),
            interval: interval,
            startDate: getStartOf(component: .weekOfYear)
        )
    }
    
    func fetchCurrentMonthCalorieData() async -> [HealthDataPoint] {
        var interval = DateComponents()
        interval.day = 1
        return await fetchHistoricalData(
            type: activeEnergyType,
            unit: .kilocalorie(),
            interval: interval,
            startDate: getStartOf(component: .month)
        )
    }
}
    
