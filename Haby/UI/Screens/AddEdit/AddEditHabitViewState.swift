
import Observation
import MapKit
import SwiftUI

@Observable
final class AddEditHabitViewState: ObservableObject {
    var isEdit: Bool = false
    
    var habit: HabitDefinition = HabitDefinition(
        name: "",
        icon: "star.fill",
        type: .OnTime,
        frequency: .Daily,
        data: .Amount(data: .init(frequency: .Daily, amount: 0, unit: .None)),
    )
    
    var amountInput: Float = 0.0
    var selectedWeekDay: WeekDay = .Monday
    var selectedHabitType: HabitType = .Deadline
    var selectedFrequency: HabitFrequency = .Daily
    var selectedDay: WeekDay = .Monday
    var selectedTime = Date()
    var selectedAmountType: AmountUnit = .None
    var healthData = false
    
    var isValid: Bool {
        if habit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        if selectedHabitType == .Amount && amountInput <= 0.0 {
            return false
        }
        
        return true
    }
    
    var finalHabit: HabitDefinition {
        var timestamp: Int? = selectedTime.hourAndMinutesToMinutesTimestamp
        if selectedFrequency == .Weekly {
            timestamp! += selectedDay.toTimestamp
        }
        if selectedHabitType == .Amount {
            timestamp = nil
        }

        var data: HabitDefinitionData {
            switch selectedHabitType {
            case .OnTime:
                return .OnTime(data: .init(frequency: selectedFrequency, minutesOfCompletionInFrequency: timestamp!))
            case .Deadline:
                return .Deadline(data: .init(frequency: selectedFrequency, minutesOfCompletionInFrequency: timestamp!))
            case .Amount:
                return .Amount(data: .init(frequency: selectedFrequency, amount: amountInput, unit: selectedAmountType))
            }
        }

        let newHabit = HabitDefinition(
            id: habit.id,
            name: habit.name,
            icon: habit.icon,
            creationDate: habit.creationDate,
            type: selectedHabitType,
            frequency: selectedFrequency,
            targetTimestamp: timestamp,
            targetValue: amountInput,
            targetValueUnit: selectedAmountType,
            isUsingHealthData: healthData,
            data: data
        )
        print(newHabit)
        return newHabit
    }
}
