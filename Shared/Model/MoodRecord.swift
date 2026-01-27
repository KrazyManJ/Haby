import UIKit

struct MoodRecord: Identifiable {
    var id: UUID
    var date: Date
    var mood: Mood
}
