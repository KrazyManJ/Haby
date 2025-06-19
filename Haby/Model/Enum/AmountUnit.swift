
import SwiftUI

enum AmountUnit: Int16, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Steps = 1
    case Kilometers = 2
    case Litres = 3
    case None = 4
    
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
        case .None:
            return ""
        }
    }
}

