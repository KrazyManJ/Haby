
import SwiftUI

struct HealthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
