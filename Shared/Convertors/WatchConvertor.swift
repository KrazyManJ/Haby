import SwiftUI

extension HabitDefinition {
    func convertToWatchData() -> [String : Any]{
        let habit: [String: Any] = [
            "id": self.id.uuidString,
            "name": self.name,
            "icon": self.icon,
            "date": self.creationDate,
            "type": self.type.rawValue,
            "frequency": self.frequency.rawValue,
            "targetTimestamp": self.targetTimestamp ?? 0,
            "targetValue": self.targetValue ?? 0.0,
            "targetValueUnit": self.targetValueUnit?.rawValue ?? 1
        ]
        return habit
    }
}

extension Array where Element == [String: Any] {
    func toHabitDefinitions() -> [HabitDefinition] {
        return self.map { $0.convertToPhoneData() }
    }
}
