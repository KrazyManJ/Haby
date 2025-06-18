import UIKit

struct HabitRecord : Identifiable {
    var id: UUID
    var habitId: UUID
    var timestamp: Int?
    var value: Float?
}

