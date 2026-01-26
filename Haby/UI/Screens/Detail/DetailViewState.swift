import Observation
import UIKit

@Observable
final class DetailViewState {
    var habit: HabitDefinition
    var record: HabitRecord?
    
    init(habit: HabitDefinition, record: HabitRecord? = nil) {
        self.habit = habit
        self.record = record
    }
    
    var status: HabitStatusHelper {
        HabitStatusHelper(habit: habit, record: record)
    }
    
    var goalAmount: Float {
        switch habit.data {
        case .Amount(let data):
            return data.amount
        default:
            return -1
        }
    }
    
    var currentAmount: Double {
        guard let record = record else { return 0.0 }
        
        switch record.data {
        case .Amount(let data):
            return Double(data.value)
        default:
            return 1.0
        }
    }
    
    var progressPercentage: Double {
        guard goalAmount > 0 else { return 0 }
        return min(currentAmount / Double(goalAmount), 1.0)
    }
}

//    var habit: HabitDefinition = HabitDefinition(
//        name: "asga",
//        icon: "star",
//        creationDate: Date(),
//        type: .Amount,
//        frequency: .Daily,
//        data: .Amount(data: .init(frequency: .Daily, amount: 5, unit: .Calories))
//    )
