import Observation
import UIKit

@Observable
final class WeeklyViewState {
    
    var habits: [HabitDefinition] = []
    var amountHabits: [HabitDefinition] = []
    //var timeHabits: [HabitDefinition] = []
    
    var habitRecords: [HabitRecord] = []
}
