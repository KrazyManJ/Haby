
import SwiftUI

struct SelectedDateData: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var mood: Mood?
    var habitRecords: [HabitRecord]
    var habitsForDate: [HabitDefinition]
}
