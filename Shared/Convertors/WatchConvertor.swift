import SwiftUI

extension HabitDefinition {
    func convertToWatchData() -> [String : Any]{
        var habit: [String: Any] = [
            "id": self.id.uuidString,
            "name": self.name,
            "icon": self.icon,
            "date": self.creationDate,
            "isUsingHealthData": self.isUsingHealthData,
            "type": self.data.type.rawValue,
            "frequency": self.data.details.frequency.rawValue,
        ]
        switch self.data {
            case .OnTime(let onTimeData):
                habit["targetTimestamp"] = onTimeData.minutesOfCompletionInFrequency
                
            case .Deadline(let deadlineData):
                habit["targetTimestamp"] = deadlineData.minutesOfCompletionInFrequency
                
            case .Amount(let amountData):
                habit["targetValue"] = amountData.amount
                habit["targetValueUnit"] = amountData.unit.rawValue
        }
        return habit
    }
}

extension Array where Element == [String: Any] {
    func toHabitDefinitions() -> [HabitDefinition] {
        return self.map { $0.convertToPhoneData() }
    }
}

extension HabitRecord {
    func convertToWatchData() -> [String: Any] {
        var record: [String: Any] = [
            "id": self.id.uuidString,
            "date": self.date,
            "habitId": self.habitDefinition.id.uuidString
        ]
        
        switch self.data {
        case .Amount(let data):
            record["recordType"] = "amount"
            record["value"] = data.value
            
        case .Deadline(let data):
            record["recordType"] = "deadline"
            record["minutes"] = data.minutesOfCompletionInFrequency
            
        case .OnTime(let data):
            record["recordType"] = "ontime"
            record["minutes"] = data.minutesOfCompletionInFrequency
        }
        
        return record
    }
}
