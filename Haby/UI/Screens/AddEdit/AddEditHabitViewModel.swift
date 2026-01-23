
import SwiftUI
import HealthKit
@Observable
class AddEditHabitViewModel {
    var state: AddEditHabitViewState = AddEditHabitViewState()

    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    @ObservationIgnored @Injected private var healthManager: HealthManaging
    @ObservationIgnored @Injected private var dataManager: DataManaging
    
    init(habit: HabitDefinition? = nil) {
        state.habitToEdit = habit
    }

    func addOrUpdateHabit(habit: HabitDefinition) {
        dataManager.upsert(model: habit)
        notificationManager.scheduleNotificationForHabit(habit: habit)
    }
    
    func requestHealthAuthorization() {
        if healthManager.hasAskedForPermission() {
            return
        }
        Task {
            _ = await healthManager.requestPermission()
        }
    }
}
