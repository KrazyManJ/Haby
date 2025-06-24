import UIKit

extension Date {

    var onlyDate: Date {
        get {
            Calendar.current.startOfDay(for: self)
        }
    }
    
    func daysAgo(_ days: Int)->Date{
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
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
    
    var shortWeekday: String {
          let formatter = DateFormatter()
          formatter.locale = Locale.current
          formatter.setLocalizedDateFormatFromTemplate("E")
          return formatter.string(from: self)
      }
    var startOfWeek: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday = 2
        let currentWeekday = calendar.component(.weekday, from: self)
        let daysToSubtract = (currentWeekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self.onlyDate)!
    }
        
    var endOfWeek: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday = 2
        let start = self.startOfWeek.onlyDate
        return calendar.date(byAdding: .day, value: 6, to: start)!
    }
}


