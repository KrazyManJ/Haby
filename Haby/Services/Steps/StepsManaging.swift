
protocol StepsManaging {
    
    func hasAskedForPermission() -> Bool

    func requestPermission() async
    
    func fetchStepsForToday() async -> Int
    
    func fetchStepsForWeek() async -> Int
    
    func fetchMonthlyStepData() async -> [StepData]
}
