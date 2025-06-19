
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
}

