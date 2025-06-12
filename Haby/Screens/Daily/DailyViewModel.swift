
import SwiftUI

@Observable
class DailyViewModel: ObservableObject {
    var state: DailyViewState = DailyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    func fetchHabits() {
        let result: [HabitDefinitionEntity] = dataManaging.wrappedValue.fetch()
        state.habits = result.map { v in v.toModel() }
    }
}
