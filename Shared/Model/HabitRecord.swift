import UIKit

struct HabitRecord : Identifiable, Codable {
    var id: UUID = UUID()
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var date: Date
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var timestamp: Int?
    @available(*, deprecated, message: "Use `data: HabitRecordData` instead") var value: Float?
    
    var habitDefinition: HabitDefinition
    
    var data: HabitRecordData
    
    static let ON_TIME_HABIT_VALID_RANGE = 5
    
    var isSatisfied: Bool {
        return habitDefinition.data.isSatisfied(for: self.data)
    }
}
