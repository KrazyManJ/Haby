
import SwiftUI

@Observable
class HabitManagementViewModel: ObservableObject {
    var state: HabitManagementViewState = HabitManagementViewState()
    
    @ObservationIgnored @Injected var dataManager: DataManaging
    @ObservationIgnored @Injected var notificationManaging: NotificationManaging
    
    var groupedHabits: [(category: String, habits: [HabitDefinition])] {
        let grouped = Dictionary(grouping: state.habits) { habit in
            habit.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "General"
                : habit.category
        }
        return grouped.sorted { $0.key < $1.key }
                      .map { (category: $0.key, habits: $0.value) }
    }
    
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
