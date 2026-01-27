import Foundation

enum HabitType: Int16, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case OnTime = 1
    case Deadline = 2
    case Amount = 3
    
    var name: String {
        switch self {
        case .OnTime:
            return NSLocalizedString("type_on_time", value: "OnTime", comment: "")
        case .Deadline:
            return NSLocalizedString("type_deadline", value: "Deadline", comment: "")
        case .Amount:
            return NSLocalizedString("type_amount", value: "Amount", comment: "")
        }
    }
    
    var description: String {
        switch self {
        case .OnTime:
            "Habit that needs to be completed in range of 5 minutes of selected time, like taking a pills."
        case .Deadline:
            "Habit that can be completed anytime before selected time (deadline), like doing a house chores."
        case .Amount:
            "Habit tracking countable completion, like walking 10 kilometers, or exercising for 2 hours."
        }
    }
}

enum HabitDefinitionData: Equatable, Codable, Hashable {
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
    
    func isSatisfied(for recordData: HabitRecordData) -> Bool {
        switch (self, recordData) {
        case (.Amount(let def), .Amount(let rec)): return def.isSatisfied(by: rec)
        case (.Deadline(let def), .Deadline(let rec)): return def.isSatisfied(by: rec)
        case (.OnTime(let def), .OnTime(let rec)): return def.isSatisfied(by: rec)
        default: return false
        }
    }
}

enum HabitRecordData : Equatable, Codable {
    case Amount(data: AmountHabitRecordData)
    case Deadline(data: DeadlineHabitRecordData)
    case OnTime(data: OnTimeHabitRecordData)
    
    var details: any HabitDataRecording {
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
}

protocol HabitDataDefining: Equatable, Codable {
    var frequency: HabitFrequency { get set }
}

protocol HabitDataRecording: Equatable, Codable {
    var date: Date { get set }
}

protocol HabitRecordValidating {
    associatedtype RecordDataType
    func isSatisfied(by recordData: RecordDataType) -> Bool
}
