import UIKit

struct HabitRecord : Identifiable {
    var id: UUID
    /** Date of completion excluding hours and minutes */
    var date: Date
    /** In minutes, if daily habit, includes minutes of completion in range from days midnight to next days midnight, only if habit is deadline or on time */
    var timestamp: Int?
    /** Measured value of habit for amount habits */
    var value: Float?
    var habitDefinition: HabitDefinition
    
    static let ON_TIME_HABIT_VALID_RANGE = 5
    
    var isCompleted: Bool {
        get {
            if let _ = habitDefinition.targetTimestamp {
                var checkingTimestamp = timestamp!
                if habitDefinition.frequency == .Weekly {
                    checkingTimestamp += date.hourAndMinutesToMinutesTimestamp
                }
                return habitDefinition.canBeCheckedInTimestamp(timestamp: checkingTimestamp)
            }
            else if let amount = habitDefinition.targetValue {
                return value! >= amount
            }
            return false
        }
    }
}

