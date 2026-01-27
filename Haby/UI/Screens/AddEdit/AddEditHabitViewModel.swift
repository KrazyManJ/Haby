
import SwiftUI
import HealthKit
@Observable
class AddEditHabitViewModel: ObservableObject {
    var state: AddEditHabitViewState = AddEditHabitViewState()

    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    @ObservationIgnored @Injected private var healthManager: HealthManaging
    @ObservationIgnored @Injected private var dataManager: DataManaging
    @ObservationIgnored @Injected private var phoneSessionManager: PhoneSessionManaging
    @ObservationIgnored @Injected private var categoryManager: CategoryManaging
    
    var availableCategories: [String] = []
    
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
        self.availableCategories = categoryManager.fetchCategories()
    }
    
    func checkHealthAuthForSelection() {
        guard state.healthData else { return }
        
        if healthManager.needsAuthorization(for: state.selectedAmountType) {
            print("🆕 User picked \(state.selectedAmountType), but permission is unknown. Asking now...")
            Task {
                await healthManager.requestAuthorization(for: state.selectedAmountType)
            }
        }
    }
    
    func updateUnitSelection(_ newUnit: AmountUnit) {
        state.selectedAmountType = newUnit
        
        if [.Steps, .Calories, .Kilometers].contains(newUnit) {
            state.healthData = true
            checkHealthAuthForSelection()
        }
    }


    func addOrUpdateHabit() {
        let categoryToSave = state.selectedCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        if !categoryToSave.isEmpty {
             categoryManager.addCategory(categoryToSave)
        }
        state.selectedCategory = categoryToSave
        let habit = state.finalHabit
        print("add",habit.id)
        dataManager.upsert(model: habit)
        notificationManager.scheduleNotificationForHabit(habit: habit)
        phoneSessionManager.syncAllHabitsToWatch()
    }
}
