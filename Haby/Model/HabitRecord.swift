import UIKit

struct HabitRecord : Identifiable {
    var id: UUID
    var timestamp: Int?
    var value: Float?
    var habitDefinition: HabitDefinition
}

