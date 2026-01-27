
import SwiftUI

enum AmountUnit: Int16, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case None = 1
    case Steps = 2
    case Kilometers = 3
    case Litres = 4
    case Hours = 5
    case Minutes = 6
    case Calories = 7
    
//    var name: String {
//        String(describing: self)
//    }
    
    // localized name
    var name: String {
        switch self {
        case .Steps:
            return NSLocalizedString("unit_steps", value: "Steps", comment: "Unit: Steps")
        case .Kilometers:
            return NSLocalizedString("unit_kilometers", value: "Kilometers", comment: "Unit: Kilometers")
        case .Litres:
            return NSLocalizedString("unit_litres", value: "Litres", comment: "Unit: Litres")
        case .Hours:
            return NSLocalizedString("unit_hours", value: "Hours", comment: "Unit: Hours")
        case .Minutes:
            return NSLocalizedString("unit_minutes", value: "Minutes", comment: "Unit: Minutes")
        case .Calories:
            return NSLocalizedString("unit_calories", value: "Calories", comment: "Unit: Calories")
        case .None:
            return ""
        }
    }
    /*
    var abbreviation: String {
        switch self {
        case .Steps:
            return "steps"
        case .Kilometers:
            return "km"
        case .Litres:
            return "l"
        case .Hours:
            return "h"
        case .Minutes:
            return "min"
        case .Calories:
            return "kcal"
        case .None:
            return ""
        }
    }
    */
    
    var abbreviation: String {
        switch self {
        case .Steps:
            return NSLocalizedString("abbr_steps", value: "steps", comment: "")
        case .Kilometers:
            return NSLocalizedString("abbr_km", value: "km", comment: "")
        case .Litres:
            return NSLocalizedString("abbr_l", value: "l", comment: "")
        case .Hours:
            return NSLocalizedString("abbr_h", value: "h", comment: "")
        case .Minutes:
            return NSLocalizedString("abbr_min", value: "min", comment: "")
        case .Calories:
            return NSLocalizedString("abbr_kcal", value: "kcal", comment: "")
        case .None:
            return ""
        }
    }
    
    var isHealthData: Bool {
        switch self {
        case .Steps, .Kilometers, .Calories: return true
        default: return false
        }
    }
}

