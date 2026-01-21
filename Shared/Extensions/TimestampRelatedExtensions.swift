
import SwiftUI

extension Int {
    func fromMinutesInDayToDate() -> Date {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .minute, value: self, to: midnight)!
    }
}
