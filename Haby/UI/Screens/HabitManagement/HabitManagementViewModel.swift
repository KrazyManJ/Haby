
import SwiftUI

@Observable
class HabitManagementViewModel: ObservableObject {
    var state: HabitManagementViewState = HabitManagementViewState()
    
    @ObservationIgnored @Injected var dataManager: DataManaging
    @ObservationIgnored @Injected var notificationManaging: NotificationManaging
    
    func fetchHabits() {
        let result: [HabitDefinitionEntity] = dataManager.fetch()
        state.habits = result.map { v in v.toModel() }
    }
    
    func removeHabit(habit: HabitDefinition) {
        if let entity: HabitDefinitionEntity = dataManager.fetchOneById(id: habit.id) {
            dataManager.delete(entity: entity)
            notificationManaging.removeNotificationForHabit(habit: habit)
            state.habits.removeAll { $0.id == habit.id }
        } else {
            print("Entity not found for id \(habit.id)")
        }
    }
}
