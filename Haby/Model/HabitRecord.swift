import UIKit

struct HabitRecord : Identifiable {
    var id: UUID
    var date: Date
    var timestamp: Int?
    var value: Float?
    var habitDefinition: HabitDefinition
    
    static let ON_TIME_HABIT_VALID_RANGE = 5
    
    var isCompletedOnTime: Bool {
        get {
            if let definitionTimestamp = habitDefinition.targetTimestamp {
                var checkingTimestamp = timestamp!
                if habitDefinition.frequency == .Weekly {
                    checkingTimestamp += date.hourAndMinutesToMinutesTimestamp
                }
                return habitDefinition.canBeCheckedInTimestamp(timestamp: checkingTimestamp)
            }
            else if let amount = habitDefinition.targetValue {
                // TODO: Implement
                return true
            }
            return false
        }
    }
}

