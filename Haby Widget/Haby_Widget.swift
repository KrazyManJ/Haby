import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private var dataManager: Injected<DataManaging> = .init()
    
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
        let habits = dataManager.wrappedValue.getTimeHabitsForToday()
        // todo get calculcate streak method
        let streak = 1
        
        let entry = HabyEntry(
                date: Date(),
                habits: habits,
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
