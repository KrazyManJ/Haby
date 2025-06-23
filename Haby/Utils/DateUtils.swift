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
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        return self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
    }
    
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        return self.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }

    func currentWeekDates(from date: Date = Date()) -> [Date] {
        let startOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
}
