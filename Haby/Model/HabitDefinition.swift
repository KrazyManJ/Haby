import UIKit

struct HabitDefinition: Identifiable {
    var id: UUID
    var name: String
    var icon: String
    
    var type: HabitType
    var frequency: HabitFrequency
    
    var targetTimestamp: Int?
    var targetValue: Float?
    var targetValueUnit: AmountUnit?
    
    var isActive: Bool = false
    var isUsingHealthData: Bool = false
    
    func canBeCheckedInTimestamp(timestamp: Int) -> Bool {
        if var definitionTimestamp = targetTimestamp {
            if type == .OnTime {
                let lowerBound = definitionTimestamp - HabitRecord.ON_TIME_HABIT_VALID_RANGE
                let higherBound = definitionTimestamp + HabitRecord.ON_TIME_HABIT_VALID_RANGE
                print(lowerBound,timestamp,higherBound)
                return (lowerBound...higherBound).contains(timestamp)
            }
            else if type == .Deadline {
                print("deadlinos",timestamp,definitionTimestamp)
                return timestamp <= definitionTimestamp
            }
        }
        else if let amount = targetValue {
            // TODO: Implement
            return true
        }
        return false
    }
}
