import UIKit

struct HabitRecord : Identifiable {
    var id: UUID = UUID()
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var date: Date
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var timestamp: Int?
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var value: Float?
    
    var habitDefinition: HabitDefinition
    
    var data: HabitRecordData
    
    static let ON_TIME_HABIT_VALID_RANGE = 5
    
    @available(*, deprecated, message: "Use isSatisfied instead")
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
    
    var isSatisfied: Bool {
        return habitDefinition.data.isSatisfied(for: self.data)
    }
}
