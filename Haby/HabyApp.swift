
import SwiftUI
import LRStreakKit

@main
struct HabyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            //.setupStreak(persistence: .custom(HabyPersistence()))
            .setupStreak(key: "CustomPersistenceKey")
        }
    }
}
