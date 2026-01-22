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
}
