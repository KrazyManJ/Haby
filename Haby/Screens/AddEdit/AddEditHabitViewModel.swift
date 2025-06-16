
import SwiftUI
@Observable
class AddEditHabitViewModel: ObservableObject {
    var state: AddEditHabitViewState = AddEditHabitViewState()
     
    private var dataManager: DataManaging
    
    init() {
        dataManager = DIContainer.shared.resolve()
    }
}

extension AddEditHabitViewModel {
    func addNewHabit(habit: HabitDefinition) {
        dataManager.upsert(entity: habit.toEntity())
    }
}
