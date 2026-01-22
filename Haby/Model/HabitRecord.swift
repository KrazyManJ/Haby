import UIKit

struct HabitRecord : Identifiable {
    var id: UUID = UUID()
    var date: Date
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var timestamp: Int?
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var value: Float?
    
    var habitDefinition: HabitDefinition
    
    var data: HabitRecordData
    
    static let ON_TIME_HABIT_VALID_RANGE = 5
    
    @available(*, deprecated, message: "Use wasDoneCorrectly instead")
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
    
    var wasDoneCorrectly: Bool {
        switch self.data {
        case .Amount(let data):
            let definitionData: AmountHabitDefinitionData = habitDefinition.data.force()
            
            return definitionData.amount <= data.value
        case .Deadline(let data):
            let definitionData: DeadlineHabitDefinitionData = habitDefinition.data.force()
            
            return definitionData.minutesOfCompletionInFrequency >= data.minutesOfCompletionInFrequency
        case .OnTime(let data):
            let definitionData: OnTimeHabitDefinitionData = habitDefinition.data.force()
            
            let ON_TIME_HABIT_MINUTES_TIME_RANGE = 5
            
            let startRange = definitionData.minutesOfCompletionInFrequency - ON_TIME_HABIT_MINUTES_TIME_RANGE
            let endRange = definitionData.minutesOfCompletionInFrequency + ON_TIME_HABIT_MINUTES_TIME_RANGE
            
            return (startRange...endRange).contains(data.minutesOfCompletionInFrequency)
        }
    }
}

struct AmountHabitRecordData {
    var value: Float
}

struct DeadlineHabitRecordData {
    var minutesOfCompletionInFrequency: Int
}

struct OnTimeHabitRecordData {
    var minutesOfCompletionInFrequency: Int
}

enum HabitRecordData {
    case Amount(data: AmountHabitRecordData)
    case Deadline(data: DeadlineHabitRecordData)
    case OnTime(data: OnTimeHabitRecordData)
}
