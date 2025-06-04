import UIKit

struct HabitDef {
    var id: UUID
    var name: String
    
    var type: HabitType
    var frequency: HabitFrequency
    
    var targetTimestamp: Int?
    var targetValue: Float?
    
    var isActive: Bool = false
}
