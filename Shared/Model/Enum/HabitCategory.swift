
import SwiftUI

enum HabitCategory: Int16, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case Wellbeing = 1
    case Health = 2
    case Work = 3
    case School = 4
    
    var name: String {
        String(describing: self)
    }
}
