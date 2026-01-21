
import SwiftUI

private struct MainTabItem<Content: View> : View {
    
    let label: String
    let systemImage: String
    let tag: Int
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .tabItem {
                Label(label, systemImage: systemImage)
                    .environment(\.symbolVariants, .none)
            }
            .tag(tag)
    }
}


struct MainTabView : View {
    
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = Colors.TextSecondary.ui
    }
    
    var body : some View {
        TabView(selection: $selectedTab){
            MainTabItem(
                label: "Daily",
                systemImage: "sun.min",
                tag: 0
            ) {
                DailyView()
            }
            MainTabItem(
                label: "Weekly",
                systemImage: "calendar",
                tag: 1
            ) {
                WeeklyView()
            }
            MainTabItem(
                label: "Habits",
                systemImage: "book",
                tag: 2
            ) {
                HabitManagementView()
            }
        }
    }
}
