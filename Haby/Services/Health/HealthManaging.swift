
import HealthKit

protocol HealthManaging {
    
    func debugHealthKit() async
        
    // auth
    func stopListening()
    func requestAuthorization(for unit: AmountUnit) async
    func needsAuthorization(for unit: AmountUnit) -> Bool
    func getQuantityType(for unit: AmountUnit) -> HKQuantityType?
    func requestPermission(type: HKQuantityType) async
    
    //observing
    func startObserver(type: HKQuantityType, onUpdate: @escaping () -> Void)
    
    func startObservingSteps(onUpdate: @escaping () -> Void)
    func startObservingCalories(onUpdate: @escaping () -> Void)
    func startObservingDistance(onUpdate: @escaping () -> Void)
    /*
    func startObservingSteps(onChange: @escaping (Double) -> Void)
    
    func startObservingDistance(onChange: @escaping (Double) -> Void)
    
    func startObservingCalories(onChange: @escaping (Double) -> Void)
    */
    //fetching
    func fetchStatistics(type: HKQuantityType, unit: HKUnit, startDate: Date, endDate: Date) async -> Double
    
    func fetchHistoricalData(type: HKQuantityType, unit: HKUnit, interval: DateComponents, startDate: Date, endDate: Date) async -> [HealthDataPoint]

    func getStartOf(component: Calendar.Component) -> Date
    
    func fetchTodaySteps() async -> Double
    
    func fetchWeekSteps() async -> Double
    
    func fetchCurrentWeekStepData() async -> [HealthDataPoint]
    
    func fetchCurrentMonthStepData() async -> [HealthDataPoint]
    
    func fetchTodayDistance() async -> Double
    
    func fetchWeekDistance() async -> Double
    
    func fetchCurrentMonthDistanceData() async -> [HealthDataPoint]
    
    func fetchTodayCalories() async -> Double
    
    func fetchWeekCalories() async -> Double
    
    func fetchCurrentWeekCalorieData() async -> [HealthDataPoint]
    
    func fetchCurrentMonthCalorieData() async -> [HealthDataPoint]
}
