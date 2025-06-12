

import SwiftUI
@Observable
class HabitManagementViewModel: ObservableObject {
    var state: HabitManagementViewState = HabitManagementViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    func fetchHabits() {
        let result: [HabitDefinitionEntity] = dataManaging.wrappedValue.fetch()
        state.habits = result.map { v in v.toModel() }
    }
}
