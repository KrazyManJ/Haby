import WidgetKit
import SwiftUI

@main
struct Haby_WidgetBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        UpcomingWidget()
        ComboWidget()
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StreakView(streak: entry.streak)
                .containerBackground(.backgroundPrimary, for: .widget)
                .preferredColorScheme(.dark)
        }
        .configurationDisplayName("Daily Streak")
        .supportedFamilies([.systemSmall])
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "UpcomingWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UpcomingHabitView(habit: entry.next)
                .containerBackground(.backgroundPrimary, for: .widget)
                .preferredColorScheme(.dark)
        }
        .configurationDisplayName("Today's Plan")
        .supportedFamilies([.systemSmall])
    }
}

struct ComboWidget: Widget {
    let kind: String = "ComboWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComboView(habits: entry.habits, streak: entry.streak)
                .containerBackground(.backgroundPrimary, for: .widget)
                .preferredColorScheme(.dark)
        }
        .configurationDisplayName("Overview")
        .supportedFamilies([.systemMedium])
    }
}
