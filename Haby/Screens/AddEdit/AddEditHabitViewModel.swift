
import SwiftUI
import HealthKit
@Observable
class AddEditHabitViewModel {
    var state: AddEditHabitViewState = AddEditHabitViewState()

    private var dataManager: Injected<DataManaging> = .init()
    private var stepsManaging: Injected<StepsManaging> = .init()
        
    init(habit: HabitDefinition? = nil) {
        state.habitToEdit = habit
    }

    func addOrUpdateHabit(habit: HabitDefinition) {
        dataManager.wrappedValue.upsert(model: habit)
    }
    
    func requestHealthAuthorization() {
        if stepsManaging.wrappedValue.hasAskedForPermission() {
            return
        }
        Task {
            _ = await stepsManaging.wrappedValue.requestPermission()
        }
    }
}
