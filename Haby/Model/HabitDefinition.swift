import UIKit

struct HabitDefinition: Identifiable, Equatable {
    var id: UUID = .init()
    var name: String
    var icon: String
    var creationDate: Date = Date()
    
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

protocol HabitDataDefining: Equatable {
    var frequency: HabitFrequency { get set }
}

struct OnTimeHabitDefinitionData : HabitDataDefining {
    var frequency: HabitFrequency
    var minutesOfCompletionInFrequency: Int
}

struct DeadlineHabitDefinitionData : HabitDataDefining {
    var frequency: HabitFrequency
    var minutesOfCompletionInFrequency: Int
}

struct AmountHabitDefinitionData : HabitDataDefining {
    var frequency: HabitFrequency
    var amount: Float
    var unit: AmountUnit
}

enum HabitDefinitionData: Equatable {
    case OnTime(data: OnTimeHabitDefinitionData)
    case Deadline(data: DeadlineHabitDefinitionData)
    case Amount(data: AmountHabitDefinitionData)
    
    var details: any HabitDataDefining {
        switch self {
            case .OnTime(let data): return data
            case .Deadline(let data): return data
            case .Amount(let data): return data
        }
    }
    
    var type: HabitType {
        switch self {
            case .OnTime: return .OnTime
            case .Amount: return .Amount
            case .Deadline: return .Deadline
        }
    }
    
    func force<T: HabitDataDefining>(as type: T.Type = T.self) -> T {
        guard let data = self.details as? T else {
            fatalError("Type Mismatch! You tried to force '\(T.self)' but the enum contains '\(Swift.type(of: self.details))'")
        }
        return data
    }
}
