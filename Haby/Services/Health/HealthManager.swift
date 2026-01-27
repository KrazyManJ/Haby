
import HealthKit
// todo add protocol back
class HealthManager: HealthManaging {
    
    private let healthStore = HKHealthStore()
    
    private var activeQueries: [HKQuery] = []
    
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    func getQuantityType(for unit: AmountUnit) -> HKQuantityType? {
        switch unit {
        case .Steps: return stepType
        case .Calories: return activeEnergyType
        case .Kilometers: return distanceType
        default: return nil
        }
    }
    
    func needsAuthorization(for unit: AmountUnit) -> Bool {
        guard let type = getQuantityType(for: unit) else { return false }
        let status = healthStore.authorizationStatus(for: type)
        return status == .notDetermined
    }
    
    func requestAuthorization(for unit: AmountUnit) async {
        guard let type = getQuantityType(for: unit) else { return }
        await requestPermission(type: type)
    }
    
    
    func requestPermission(type: HKQuantityType) async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let types: Set = [type]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: types)
            print("HealthKit request presented")
        } catch {
            print("Error requesting HealthKit: \(error.localizedDescription)")
        }
    }
    
    internal func startObserver(type: HKQuantityType, fetcher: @escaping () async -> Double, onChange: @escaping (Double) -> Void) {
        healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
            if let error = error {
                print("⚠️ Failed to enable background delivery for \(type): \(error.localizedDescription)")
            } else {
                print("✅ Background delivery enabled for \(type)")
            }
        }
        
        let observerQuery = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] query, completion, error in
            guard self != nil else { return }
            
            if let error = error {
                print("❌ Observer Error: \(error.localizedDescription)")
                completion()
                return
            }
            
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                let newTotal = await fetcher()
                await MainActor.run {
                    onChange(newTotal)
                }
                completion()
            }
        }
        
        healthStore.execute(observerQuery)
        activeQueries.append(observerQuery)
    }
    
    func stopListening() {
        for query in activeQueries {
            healthStore.stop(query)
        }
        activeQueries.removeAll()
    }
    
    func startObservingSteps(onChange: @escaping (Double) -> Void) {
        startObserver(type: stepType) { [weak self] in
            guard let self = self else { return 0.0 }
            return await self.fetchTodaySteps()
        } onChange: { val in
            onChange(val)
        }
    }
    
    func startObservingCalories(onChange: @escaping (Double) -> Void) {
        startObserver(type: activeEnergyType) { [weak self] in
            guard let self = self else { return 0.0 }
            return await self.fetchTodayCalories()
        } onChange: { val in
            onChange(val)
        }
    }
    
    func startObservingDistance(onChange: @escaping (Double) -> Void) {
        startObserver(type: distanceType) { [weak self] in
            guard let self = self else { return 0.0 }
            return await self.fetchTodayDistance()
        } onChange: { val in
            onChange(val)
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
/*
     */
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
            unit: .meterUnit(with: .kilo),
            startDate: Calendar.current.startOfDay(for: Date())
        )
    }
    
    func fetchWeekDistance() async -> Double {
        return await fetchStatistics(
            type: distanceType,
            unit: .meterUnit(with: .kilo),
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
            unit: .meterUnit(with: .kilo),
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

    // call in onAppear
    func debugHealthKit() async {
        let type = HKQuantityType(.stepCount)
        let status = healthStore.authorizationStatus(for: type)
        
        print("🫀 Authorization Status: \(status.rawValue)")
        // 0 = notDetermined, 1 = sharingDenied, 2 = sharingAuthorized
        
        // Attempt to fetch raw samples (not statistics)
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-86400), end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 10, sortDescriptors: [sortDescriptor]) { _, samples, error in
            
            if let error = error {
                print("❌ Query Error: \(error.localizedDescription)")
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                print("⚠️ Query Success, but Returned 0 Samples. (Permission issue or No Data)")
                return
            }
            
            for sample in samples {
                let val = sample.quantity.doubleValue(for: .count())
                print("✅ Found Sample: \(val) steps at \(sample.startDate)")
            }
        }
        
        healthStore.execute(query)
    }
    
}
    
