
import Foundation

enum WeekDay: Int, CaseIterable, Identifiable {
    
    static let MINUTES_IN_DAY: Int = 1440;
    
    var id: Self { self }
    
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    case Sunday = 7
    
    var name: String {
        String(describing: self)
    }
    
    var toTimestamp: Int {
        return self.rawValue*WeekDay.MINUTES_IN_DAY
    }
    
    static func getTodayWeekDay() -> WeekDay {
        return WeekDay(rawValue: Calendar.current.component(.weekday, from: Date()))!
    }
    static func getTomorrowWeekDay() -> WeekDay {
        return WeekDay(rawValue: Calendar.current.component(.weekday, from: Date())+1)!
    }
}
