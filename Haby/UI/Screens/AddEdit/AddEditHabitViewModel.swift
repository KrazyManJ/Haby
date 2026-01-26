
import SwiftUI
import HealthKit
@Observable
class AddEditHabitViewModel: ObservableObject {
    var state: AddEditHabitViewState = AddEditHabitViewState()

    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    @ObservationIgnored @Injected private var healthManager: HealthManaging
    @ObservationIgnored @Injected private var dataManager: DataManaging
    
    init(habit: HabitDefinition? = nil) {
        if let habit = habit {
            state.habit = habit
            print("Changed")
            print(habit.id)
            
            state.selectedHabitType = habit.data.type
            state.selectedFrequency = habit.data.details.frequency
            state.healthData = habit.isUsingHealthData
            
            switch habit.data {
            case .OnTime(let data):
                state.selectedTime = Date.fromMinutesTimestamp(timestamp: data.minutesOfCompletionInFrequency)
                if data.frequency == .Weekly {
                    state.selectedDay = WeekDay(from: data.minutesOfCompletionInFrequency)
                }
            case .Deadline(let data):
                state.selectedTime = Date.fromMinutesTimestamp(timestamp: data.minutesOfCompletionInFrequency)
                if data.frequency == .Weekly {
                    state.selectedDay = WeekDay(from: data.minutesOfCompletionInFrequency)
                }
            case .Amount(let data):
                state.amountInput = data.amount
                state.selectedAmountType = data.unit
            }
            
            state.isEdit = true
        }
    }

    func addOrUpdateHabit() {
        let habit = state.finalHabit
        print("add",habit.id)
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
