
import SwiftUI

enum AccessibilityTag: String {
    case MainTabView_DailyTabButton
    case MainTabView_WeeklyTabButton
    case MainTabView_HabitsTabButton
    case MainTabView_StreakToolbarItem
    case MainTabView_AddHabitToolbarItem
    
    case StreakToolbarItem_StreakText
    
    case AddEditHabitView_NameInput
    case AddEditHabitView_SaveButton
    
    case HabitDefinitionRow_Element
    case HabitDefinitionRow_Name
}

private let accessibilityDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

enum VariableAccessibilityTag {
    case FSCalendarView_Cell(date: Date)
    
    var rawValue: String {
        return switch self {
        case .FSCalendarView_Cell(let date): "FSCalendarView_Cell_\(accessibilityDateFormatter.string(from: date))"
        }
    }
}

extension View {
    func accessibilityIdentifier(_ tag: AccessibilityTag) -> some View {
        self.accessibilityIdentifier(tag.rawValue)
    }
    func accessibilityIdentifier(_ tag: VariableAccessibilityTag) -> some View {
        self.accessibilityIdentifier(tag.rawValue)
    }
}
