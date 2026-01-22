
import SwiftUI
import HealthKit
@Observable
class AddEditHabitViewModel {
    var state: AddEditHabitViewState = AddEditHabitViewState()

    private var dataManager: Injected<DataManaging> = .init()
    private var healthManager: Injected<HealthManaging> = .init()
        
    init(habit: HabitDefinition? = nil) {
        state.habitToEdit = habit
    }

    func addOrUpdateHabit(habit: HabitDefinition) {
        print(habit)
        dataManager.wrappedValue.upsert(model: habit)
    }
    
    func requestHealthAuthorization() {
        if healthManager.wrappedValue.hasAskedForPermission() {
            return
        }
        Task {
            _ = await healthManager.wrappedValue.requestPermission()
        }
    }
}
