
enum InternalHabitCategory {
    case Numeric
    case Timer
    
    var matchingTypes: [HabitType] {
        switch self {
        case .Numeric: return [HabitType.Amount]
        case .Timer: return [HabitType.OnTime, HabitType.Deadline]
        }
    }
}

extension Array where Element: RawRepresentable {
    var rawValues: [Element.RawValue] { self.map{ $0.rawValue } }
}

extension HabitType {
    var internalCategory: InternalHabitCategory {
        switch self {
        case .Amount:
            return .Numeric
        case .OnTime, .Deadline:
            return .Timer
        }
    }
}

