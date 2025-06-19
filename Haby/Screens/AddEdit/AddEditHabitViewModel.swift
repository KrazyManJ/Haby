
import SwiftUI
import HealthKit
@Observable
class AddEditHabitViewModel {
    var state: AddEditHabitViewState = AddEditHabitViewState()
    var habitToEdit: HabitDefinition?

    var healthData: Bool {
        get { internalHealthData }
        set {
            internalHealthData = newValue
            if newValue {
                requestHealthAuthorization()
            }
        }
    }
    
    private var internalHealthData: Bool = false

    private var dataManager: DataManaging
        
    init(habit: HabitDefinition? = nil) {
        self.habitToEdit = habit
        self.dataManager = DIContainer.shared.resolve()
        self.healthData = habit?.isUsingHealthData ?? false
    }

    func addOrUpdateHabit(habit: HabitDefinition) {
           dataManager.upsert(model: habit)
    }
    
    func requestHealthAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let healthStore = HKHealthStore()
        
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            } else if success {
                print("✅ HealthKit access granted")
            } else {
                print("❌ HealthKit access denied")
            }
        }
    }
    
}
