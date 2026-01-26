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
            streak: 5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HabyEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabyEntry>) -> ()) {
        var entries: [HabyEntry] = []
        let timeHabits = dataManager.getTimeHabitsForToday()
        let amountHabits = dataManager.getAmountHabitsForToday()
        let habits = timeHabits + amountHabits
        let records = dataManager.getTodayRecords()
        let upcomingHabits = habits.filter { habit in
            let record = records.first {
                $0.habitDefinition.id == habit.id
            }
            let status = HabitStatusHelper(habit: habit, record: record)
            return !status.isCompleted
        }
            
        print("got habits \(upcomingHabits.count)")
        // todo get calculcate streak method
        let streak = habitManager.calculateCurrentStreak()
        print("got streak \(streak)")
        
        let entry = HabyEntry(
                date: Date(),
                habits: upcomingHabits,
                streak: streak
            )
            
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct HabyEntry: TimelineEntry {
    let date: Date
    let habits: [HabitDefinition]
    let streak: Int
}
