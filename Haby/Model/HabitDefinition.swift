import UIKit

struct HabitDefinition: Identifiable, Equatable, Codable {
    var id: UUID = .init()
    var name: String
    var icon: String
    var creationDate: Date = Date().onlyDate
    var category: String
    
    @available(*, deprecated, message: "Use `data: HabyData` instead") var type: HabitType
    @available(*, deprecated, message: "Use `data: HabyData` instead") var frequency: HabitFrequency
    
    @available(*, deprecated, message: "Use `data: HabyData` instead") var targetTimestamp: Int?
    @available(*, deprecated, message: "Use `data: HabyData` instead") var targetValue: Float?
    @available(*, deprecated, message: "Use `data: HabyData` instead") var targetValueUnit: AmountUnit?
    
    var isUsingHealthData: Bool = false
    
    var data: HabitDefinitionData
    
    func canBeCheckedInTimestamp(timestamp: Int) -> Bool {
        if let definitionTimestamp = targetTimestamp {
            if type == .OnTime {
                let lowerBound = definitionTimestamp - HabitRecord.ON_TIME_HABIT_VALID_RANGE
                let higherBound = definitionTimestamp + HabitRecord.ON_TIME_HABIT_VALID_RANGE
                return (lowerBound...higherBound).contains(timestamp)
            }
            else if type == .Deadline {
                return timestamp <= definitionTimestamp
            }
        }
        return false
    }
}
