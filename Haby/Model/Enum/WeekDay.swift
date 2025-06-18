
import Foundation

enum WeekDay: Int16, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    case Sunday = 7
    
    var name: String {
        String(describing: self)
    }
}
