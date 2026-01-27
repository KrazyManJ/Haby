import UIKit

extension Date {

    var onlyDate: Date {
        get {
            Calendar.currentWithMondayAsSWeekStartDay.startOfDay(for: self)
        }
    }
    
    func daysAgo(_ days: Int)->Date{
        Calendar.currentWithMondayAsSWeekStartDay.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    var nextDay: Date {
        Calendar.currentWithMondayAsSWeekStartDay.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    var hourAndMinutesToMinutesTimestamp: Int {
        get {
            let calendar = Calendar.currentWithMondayAsSWeekStartDay
            let components = calendar.dateComponents([.hour, .minute], from: self)

            let hour = components.hour ?? 0
            let minute = components.minute ?? 0

            return hour * 60 + minute
        }
    }
    
    func toDisplayFormat(format: String = "MM. dd. yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format

        return formatter.string(from: self)
    }
    
    static func fromMinutesTimestamp(timestamp: Int) -> Date {
        let calendar = Calendar.currentWithMondayAsSWeekStartDay
        let midnight = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .minute, value: timestamp, to: midnight)!
    }
    
    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("E")
        return formatter.string(from: self)
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.currentWithMondayAsSWeekStartDay
        let currentWeekday = calendar.component(.weekday, from: self)
        let daysToSubtract = (currentWeekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self.onlyDate)!
    }
        
    var endOfWeek: Date {
        let calendar = Calendar.currentWithMondayAsSWeekStartDay
        let start = self.startOfWeek.onlyDate
        return calendar.date(byAdding: .day, value: 6, to: start)!
    }
    
    func minutesFromStartOfWeek() -> Int {
        let calendar = Calendar.currentWithMondayAsSWeekStartDay
        let start = self.startOfWeek
        let components = calendar.dateComponents([.minute], from: start, to: self)
        return components.minute ?? 0
    }
        
    func minutesFromStartOfDay() -> Int {
        let calendar = Calendar.currentWithMondayAsSWeekStartDay
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
    
    var weekday: WeekDay {
        return WeekDay(from: self)
    }
}


