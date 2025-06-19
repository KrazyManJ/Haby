import UIKit

extension Date {

    var onlyDate: Date {
        get {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calendar.date(from: dateComponents)!
        }
    }
    
    var hourAndMinutesToMinutesTimestamp: Int {
        get {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: self)

            let hour = components.hour ?? 0
            let minute = components.minute ?? 0

            return hour * 60 + minute
        }
    }
    
    func toDisplayFormat(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format

        return formatter.string(from: self)
    }
    
    static func fromMinutesTimestamp(timestamp: Int) -> Date {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .minute, value: timestamp, to: midnight)!
    }
}
