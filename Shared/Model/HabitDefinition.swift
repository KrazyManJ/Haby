import UIKit

struct HabitDefinition: Identifiable, Equatable, Codable, Hashable {
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
}
