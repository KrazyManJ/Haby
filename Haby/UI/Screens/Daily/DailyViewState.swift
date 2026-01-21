import Observation
import UIKit

@Observable
final class DailyViewState {
    var todayMoodData: MoodRecord = MoodRecord(
        id: UUID(), date: Date().onlyDate, mood: .Neutral
    )
    
    var habits: [HabitDefinition] = []
    var amountHabits: [HabitDefinition] = []
    
    var habitRecords: [HabitRecord] = []
}
