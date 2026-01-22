import SwiftUI

extension Dictionary where Key == String {
    func convertToPhoneData() -> HabitDefinition {
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
        )
        return habit
    }
}
