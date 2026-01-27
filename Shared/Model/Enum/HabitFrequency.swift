import SwiftUI

enum HabitFrequency: Int16, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case Daily = 1
    case Weekly = 2
    
    var name: String {
        switch self {
        case .Daily:
            return NSLocalizedString("frequency_daily", value: "Daily", comment: "")
        case .Weekly:
            return NSLocalizedString("frequency_weekly", value: "Weekly", comment: "")
        }
    }
}
