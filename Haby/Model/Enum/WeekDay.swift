
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
        return (self.rawValue-1)*WeekDay.MINUTES_IN_DAY
    }
    
    static func getTodayWeekDay() -> WeekDay {
        let calendarWeekday = Calendar.current.component(.weekday, from: Date())
        let mappedRawValue = calendarWeekday == 1 ? 7 : calendarWeekday - 1
        return WeekDay(rawValue: mappedRawValue)!
    }
    
    static func getTomorrowWeekDay() -> WeekDay {
        let today = getTodayWeekDay().rawValue
        let tomorrow = today % 7 + 1
        return WeekDay(rawValue: tomorrow)!
    }
    
    init(from timestamp: Int) {
        self = WeekDay(rawValue: timestamp/WeekDay.MINUTES_IN_DAY+1)!
    }
}
