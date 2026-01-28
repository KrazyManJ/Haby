import SwiftUI
import WidgetKit

struct HabyEntry: TimelineEntry {
    let date: Date
    let habits: [HabitDefinition]
    let streak: Int
    let next: HabitDefinition?
}

struct TimelineLogic {
    static func calculateEntries(
        currentDate: Date,
        calendar: Calendar,
        streak: Int,
        timeHabits: [HabitDefinition],
        amountHabits: [HabitDefinition],
        records: [HabitRecord]
    ) -> [HabyEntry] {
        var entries: [HabyEntry] = []
        let startOfDay = calendar.startOfDay(for: currentDate)
        func getMinutes(from habit: HabitDefinition) -> Int {
            switch habit.data {
            case .OnTime(let data): return data.minutesOfCompletionInFrequency
            case .Deadline(let data): return data.minutesOfCompletionInFrequency
            default: return Int.max
            }
        }
            let sortedTimeHabits = timeHabits.sorted { getMinutes(from: $0) < getMinutes(from: $1) }
            let allUpcomingHabits = (sortedTimeHabits + amountHabits).filter { habit in
                let matches = records.filter { $0.habitDefinition.id == habit.id }
                let record = matches.first(where: { HabitStatusHelper(habit: habit, record: $0).isCompleted }) ?? matches.first
                let status = HabitStatusHelper(habit: habit, record: record)
                return !status.isCompleted && !status.isOverdue
            }
            let firstEntry = HabyEntry(
                date: currentDate,
                habits: allUpcomingHabits,
                streak: streak,
                next: allUpcomingHabits.first
            )
            entries.append(firstEntry)
            
            for habit in sortedTimeHabits {
                let habitMinutes = getMinutes(from: habit)
                
                guard habitMinutes < Int.max else { continue }
                
                if let dueDate = calendar.date(byAdding: .minute, value: habitMinutes, to: startOfDay) {
                    let switchTime = dueDate.addingTimeInterval(5)
                    
                    if switchTime > currentDate {
                        let futureList = allUpcomingHabits.filter { h in
                            let hMin = getMinutes(from: h)
                            return hMin > habitMinutes
                        }
                        
                        let entry = HabyEntry(
                            date: switchTime,
                            habits: futureList,
                            streak: streak,
                            next: futureList.first
                        )
                        
                        entries.append(entry)
                    }
                }
            }
        return entries
    }
}
