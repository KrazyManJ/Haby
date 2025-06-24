
import SwiftUI

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
