//import XCTest
//@testable import Haby
//
//class TimelineLogicTests: XCTestCase {
//
//    func testGetNextHabit_SelectsFirstUpcomingHabit() {
//        let now = Date()
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.hour, .minute], from: now)
//        let currentMinutesFromMidnight = (components.hour! * 60) + components.minute!
//        
//        let minutesAgo = currentMinutesFromMidnight - 60
//        let habitA = HabitDefinition(
//            name: "Past habit",
//            icon: "star.fill",
//            category: "Wellbeing",
//            type: .OnTime,
//            frequency: .Daily,
//            data: .OnTime(
//                data: .init(
//                    frequency: .Daily,
//                    minutesOfCompletionInFrequency: minutesAgo
//                )
//            )
//        )
//        
//        let minutesFuture = currentMinutesFromMidnight + 60
//        let habitB = HabitDefinition(
//            name: "Future habit",
//            icon: "heart.fill",
//            category: "Wellbeing",
//            type: .OnTime,
//            frequency: .Daily,
//            data: .OnTime(
//                data: .init(
//                    frequency: .Daily,
//                    minutesOfCompletionInFrequency: minutesFuture
//                )
//            )
//        )
//        
//        let minutesFuture2 = currentMinutesFromMidnight + 120
//        let habitC = HabitDefinition(
//            name: "Far Far Future habit",
//            icon: "car.fill",
//            category: "Wellbeing",
//            type: .OnTime,
//            frequency: .Daily,
//            data: .OnTime(
//                data: .init(
//                    frequency: .Daily,
//                    minutesOfCompletionInFrequency: minutesFuture2
//                )
//            )
//        )
//        
//        let entries = TimelineLogic.calculateEntries(
//            currentDate: now,
//            calendar: calendar,
//            streak: 5,
//            timeHabits: [habitA, habitB, habitC],
//            amountHabits: [],
//            records: []
//        )
//
//        let firstEntry = entries.first
//        
//        XCTAssertNotEqual(firstEntry?.next?.id, habitA.id, "Habit A should be skipped because it is overdue")
//                
//        XCTAssertEqual(firstEntry?.next?.id, habitB.id, "Habit B should be next because it is the earliest non-overdue habit")
//        
//        XCTAssertTrue(entries.count >= 2)
//    }
//}
