import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @Injected private var dataManager: DataManaging
    @Injected private var habitManager: HabitManaging
    
    func placeholder(in context: Context) -> HabyEntry {
        HabyEntry(
            date: Date(),
            habits: [
                //                HabitDefinition(name: "Morning Yoga", icon: "figure.yoga", data: ...),
                //                HabitDefinition(name: "Drink Water", icon: "drop.fill", data: ...)
            ],
            streak: 5,
            next: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabyEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabyEntry>) -> ()) {
        // 1. Gather Dependencies
        let currentDate = Date()
        let streak = habitManager.calculateCurrentStreak()
        let timeHabits = dataManager.getTimeHabitsForToday()
        let amountHabits = dataManager.getAmountHabitsForToday()
        let records = dataManager.getTodayRecords()
        
        // 2. Call the Testable Logic
        let entries = TimelineLogic.calculateEntries(
            currentDate: currentDate,
            calendar: Calendar.current,
            streak: streak,
            timeHabits: timeHabits,
            amountHabits: amountHabits,
            records: records
        )
        
        // 3. Return to WidgetKit
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    /*
     func getTimeline(in context: Context, completion: @escaping (Timeline<HabyEntry>) -> ()) {
     var entries: [HabyEntry] = []
     
     let currentDate = Date()
     let calendar = Calendar.current
     let startOfDay = calendar.startOfDay(for: currentDate)
     
     let streak = habitManager.calculateCurrentStreak()
     
     var nextHabit: HabitDefinition? = nil
     let timeHabits = dataManager.getTimeHabitsForToday()
     let amountHabits = dataManager.getAmountHabitsForToday()
     var sortedTimeHabits: [HabitDefinition] = []
     
     func getMinutes(from habit: HabitDefinition) -> Int {
     switch habit.data {
     case .OnTime(let data): return data.minutesOfCompletionInFrequency
     case .Deadline(let data): return data.minutesOfCompletionInFrequency
     default: return Int.max                }
     }
     
     sortedTimeHabits = timeHabits.sorted { habit1, habit2 in
     return getMinutes(from: habit1) < getMinutes(from: habit2)
     }
     
     let records = dataManager.getTodayRecords()
     
     let allUpcomingHabits = (sortedTimeHabits + amountHabits).filter { habit in
     let matches = records.filter { $0.habitDefinition.id == habit.id }
     let record = matches.first(where: { HabitStatusHelper(habit: habit, record: $0).isCompleted }) ?? matches.first
     let status = HabitStatusHelper(habit: habit, record: record)
     return !status.isCompleted && !status.isOverdue
     }
     
     if(!allUpcomingHabits.isEmpty){
     nextHabit = allUpcomingHabits.first
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
     
     if switchTime > Date() {
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
     let timeline = Timeline(entries: entries, policy: .atEnd)
     completion(timeline)
     }
     */
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


struct HabyEntry: TimelineEntry {
    let date: Date
    let habits: [HabitDefinition]
    let streak: Int
    let next: HabitDefinition?
}

