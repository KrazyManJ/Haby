import Observation
import UIKit

@Observable
final class DetailViewState {
//    var habit: HabitDefinition = HabitDefinition(
//        name: "asga",
//        icon: "star",
//        creationDate: Date(),
//        type: .Amount,
//        frequency: .Daily,
//        data: .Amount(data: .init(frequency: .Daily, amount: 5, unit: .Calories))
//    )
    var habit: HabitDefinition
    var record: HabitRecord?
    
    init(habit: HabitDefinition, record: HabitRecord? = nil) {
        self.habit = habit
        self.record = record
    }
}
