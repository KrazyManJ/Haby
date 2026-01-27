
import SwiftUI

extension Calendar {
    
    static var currentWithMondayAsSWeekStartDay: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }
    
    func currentWeekDates(from date: Date = Date()) -> [Date] {
        let startOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        return self.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }
}
