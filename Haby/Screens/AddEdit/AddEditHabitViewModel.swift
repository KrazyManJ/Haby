
import SwiftUI
@Observable
class AddEditHabitViewModel: ObservableObject {
    var state: AddEditHabitViewState = AddEditHabitViewState()
    var habitToEdit: HabitDefinition?
     
    private var dataManager: DataManaging
        
    init(habit: HabitDefinition? = nil) {
        self.habitToEdit = habit
        self.dataManager = DIContainer.shared.resolve()
    }
}

extension AddEditHabitViewModel {
    func addOrUpdateHabit(habit: HabitDefinition) {
           dataManager.upsert(model: habit)
    }
}
