
import SwiftUI

enum HabitCategory: Int16, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case Wellbeing = 1
    case Health = 2
    case Work = 3
    case School = 4
    
    var name: String {
        switch self {
        case .Wellbeing:
            return NSLocalizedString("category_wellbeing", value: "Wellbeing", comment: "")
        case .Health:
            return NSLocalizedString("category_health", value: "Health", comment: "")
        case .Work:
            return NSLocalizedString("category_work", value: "Work", comment: "")
        case .School:
            return NSLocalizedString("category_school", value: "School", comment: "")
        }
    }
}
