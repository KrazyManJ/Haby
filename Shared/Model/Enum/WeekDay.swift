
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
        switch self {
        case .Monday:
            return NSLocalizedString("weekday_monday", value: "Monday", comment: "")
        case .Tuesday:
            return NSLocalizedString("weekday_tuesday", value: "Tuesday", comment: "")
        case .Wednesday:
            return NSLocalizedString("weekday_wednesday", value: "Wednesday", comment: "")
        case .Thursday:
            return NSLocalizedString("weekday_thursday", value: "Thursday", comment: "")
        case .Friday:
            return NSLocalizedString("weekday_friday", value: "Friday", comment: "")
        case .Saturday:
            return NSLocalizedString("weekday_saturday", value: "Saturday", comment: "")
        case .Sunday:
            return NSLocalizedString("weekday_sunday", value: "Sunday", comment: "")
        }
    }
    
    var toTimestamp: Int {
        return (self.rawValue-1)*WeekDay.MINUTES_IN_DAY
    }
    
    static func getTodayWeekDay() -> WeekDay {
        return WeekDay(from: Date())
    }
    
    static func getTomorrowWeekDay() -> WeekDay {
        let today = getTodayWeekDay().rawValue
        let tomorrow = today % 7 + 1
        return WeekDay(rawValue: tomorrow)!
    }
    
    init(from timestamp: Int) {
        self = WeekDay(rawValue: timestamp/WeekDay.MINUTES_IN_DAY+1)!
    }
    
    func nextDay() -> WeekDay {
        let nextRawValue = (self.rawValue % 7) + 1
        return WeekDay(rawValue: nextRawValue)!
    }
    
    init(from date: Date) {
        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        let mappedRawValue = calendarWeekday == 1 ? 7 : calendarWeekday - 1
        self = WeekDay(rawValue: mappedRawValue)!
    }
}
