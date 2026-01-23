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

protocol HabitRecordValidating {
    associatedtype RecordDataType
    func isSatisfied(by recordData: RecordDataType) -> Bool
}


struct OnTimeHabitDefinitionData : HabitDataDefining, HabitRecordValidating {
    var frequency: HabitFrequency
    var minutesOfCompletionInFrequency: Int
    
    static let VALID_TIME_RANGE_IN_MINUTES = 5
    
    func isSatisfied(by recordData: OnTimeHabitRecordData) -> Bool {
        
        let ON_TIME_HABIT_MINUTES_TIME_RANGE = 5
        
        let startRange = self.minutesOfCompletionInFrequency - ON_TIME_HABIT_MINUTES_TIME_RANGE
        let endRange = self.minutesOfCompletionInFrequency + ON_TIME_HABIT_MINUTES_TIME_RANGE
        
        return (startRange...endRange).contains(recordData.minutesOfCompletionInFrequency)
    }
}

struct DeadlineHabitDefinitionData : HabitDataDefining, HabitRecordValidating {
    var frequency: HabitFrequency
    var minutesOfCompletionInFrequency: Int
    
    func isSatisfied(by recordData: DeadlineHabitRecordData) -> Bool {
        return self.minutesOfCompletionInFrequency >= recordData.minutesOfCompletionInFrequency
    }
}

struct AmountHabitDefinitionData : HabitDataDefining, HabitRecordValidating {
    var frequency: HabitFrequency
    var amount: Float
    var unit: AmountUnit
    
    func isSatisfied(by recordData: AmountHabitRecordData) -> Bool {
        return self.amount <= recordData.value
    }
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

extension HabitDefinitionData {
    func isSatisfied(for recordData: HabitRecordData) -> Bool {
        switch (self, recordData) {
        case (.Amount(let def), .Amount(let rec)): return def.isSatisfied(by: rec)
        case (.Deadline(let def), .Deadline(let rec)): return def.isSatisfied(by: rec)
        case (.OnTime(let def), .OnTime(let rec)): return def.isSatisfied(by: rec)
        default: return false
        }
    }
}
