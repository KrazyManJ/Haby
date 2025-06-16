

import SwiftUI
@Observable
class HabitManagementViewModel: ObservableObject {
    var state: HabitManagementViewState = HabitManagementViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    private var dataManager: DataManaging
    
    init() {
        dataManager = DIContainer.shared.resolve()
    }
    
    func fetchHabits() {
        let result: [HabitDefinitionEntity] = dataManaging.wrappedValue.fetch()
        state.habits = result.map { v in v.toModel() }
    }
    
    func removeHabit(habit: HabitDefinition) {
        if let entity: HabitDefinitionEntity = dataManager.fetchOneById(id: habit.id) {
            dataManager.delete(entity: entity)
            state.habits.removeAll { $0.id == habit.id }
        } else {
            print("Entity not found for id \(habit.id)")
        }
    }
    
}
