
import HealthKit

protocol HealthManaging {
    
    func hasAskedForPermission() -> Bool
    
    func requestPermission() async
    
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
    
    func fetchTodayWorkoutTime() async -> Double
    
    func fetchWeekWorkoutTime() async -> Double
    
    func fetchCurrentMonthWorkoutTimeData() async -> [HealthDataPoint]
    
    func fetchTodayCalories() async -> Double
    
    func fetchWeekCalories() async -> Double
    
    func fetchCurrentWeekCalorieData() async -> [HealthDataPoint]
    
    func fetchCurrentMonthCalorieData() async -> [HealthDataPoint]
}
