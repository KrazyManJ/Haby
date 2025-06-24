
import SwiftUI

enum AmountUnit: Int16, CaseIterable, Identifiable {
    var id: Self { self }
    
    case None = 1
    case Steps = 2
    case Kilometers = 3
    case Litres = 4
    case Hours = 5
    case Minutes = 6
    
    var name: String {
        String(describing: self)
    }
    
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
        case .None:
            return ""
        }
    }
}

