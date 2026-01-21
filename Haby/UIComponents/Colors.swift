
import SwiftUI

enum Colors {
    static let Primary = Color(.primary)
    
    static let BackgroundPrimary = Color(.backgroundPrimary)
    static let BackgroundSecondary = Color(.backgroundSecondary)
    
    static let TextPrimary = Color(.textPrimary)
    static let TextSecondary = Color(.textSecondary)
    
    static let Destructive = Color(.destructive)
    
    static let Experiment = Color(.experiment)
}

extension Color {
    var ui: UIColor { UIColor(self) }
}
