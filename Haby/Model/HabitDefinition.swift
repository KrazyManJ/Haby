import UIKit

struct HabitDefinition: Identifiable {
    var id: UUID
    var name: String
    var icon: String
    
    var type: HabitType
    var frequency: HabitFrequency
    
    var targetTimestamp: Int?
    var targetValue: Float?
    var targetValueUnit: String?
    
    var isActive: Bool = false
    var isUsingHealthData: Bool = false
}
