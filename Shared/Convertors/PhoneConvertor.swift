import SwiftUI

extension Dictionary where Key == String {
    func convertToPhoneData() -> HabitDefinition {
        let type: HabitType = HabitType(rawValue: self["type"] as! Int16)!
        let frequency = HabitFrequency(rawValue: self["frequency"] as! Int16)!
        
        var data: HabitDefinitionData {
            switch type {
            case .Amount:
                return .Amount(data: .init(
                    frequency: frequency,
                    amount: Float(self["targetValue"] as! Float),
                    unit: AmountUnit(rawValue: self["targetValueUnit"] as! Int16)!
                ))
            case .Deadline:
                return .Deadline(data: .init(
                    frequency: frequency,
                    minutesOfCompletionInFrequency: self["targetTimestamp"] as! Int
                ))
            case .OnTime:
                return .OnTime(data: .init(
                    frequency: frequency,
                    minutesOfCompletionInFrequency: self["targetTimestamp"] as! Int
                ))
            }
        }
        
        let habit = HabitDefinition(
            id: UUID(uuidString: self["id"] as? String ?? "") ?? UUID(),
            name: self["name"] as? String ?? "No name",
            icon: self["icon"] as? String ?? "star.fill",
            creationDate: self["date"] as? Date ?? .now,
            type: HabitType(rawValue: self["type"] as? Int16 ?? 0) ?? .Deadline,
            frequency: HabitFrequency(rawValue: self["frequency"] as? Int16 ?? 0) ?? .Daily,
            targetTimestamp: self["targetTimestamp"] as? Int,
            targetValue: self["targetValue"] as? Float,
            targetValueUnit: AmountUnit(rawValue: self["targetValueUnit"] as? Int16 ?? 0) ?? .None,
            data: data
        )
        return habit
    }
    
    func convertToRecord(using definitions: [HabitDefinition]) -> HabitRecord? {
        guard let idString = self["id"] as? String,
              let id = UUID(uuidString: idString),
              let date = self["date"] as? Date,
              let habitIdString = self["habitId"] as? String,
              let habitId = UUID(uuidString: habitIdString),
              let typeString = self["recordType"] as? String
        else {
            return nil
        }
        
        guard let parentDefinition = definitions.first(where: { $0.id == habitId }) else {
            print("Received record for unknown habit ID: \(habitId)")
            return nil
        }
        
        let recordData: HabitRecordData
        
        switch typeString {
        case "amount":
            let val = self["value"] as? Float ?? 0.0
            recordData = .Amount(data: AmountHabitRecordData(date: date, value: val))
            
        case "deadline":
            let mins = self["minutes"] as? Int ?? 0
            recordData = .Deadline(data: DeadlineHabitRecordData(date: date, minutesOfCompletionInFrequency: mins))
            
        case "ontime":
            let mins = self["minutes"] as? Int ?? 0
            recordData = .OnTime(data: OnTimeHabitRecordData(date: date, minutesOfCompletionInFrequency: mins))
            
        default:
            return nil
        }
        
        return HabitRecord(
            id: id,
            date: date,
            timestamp: nil, // Deprecated
            value: nil,     // Deprecated
            habitDefinition: parentDefinition,
            data: recordData
        )
    }
}


