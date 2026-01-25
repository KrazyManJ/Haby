import Foundation

extension Date {
    var normalizedDate: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
