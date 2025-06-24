
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        
        UINavigationBar.appearance().tintColor = UIColor(Color.Primary)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // makes it non-transparent
        appearance.backgroundColor = UIColor(Color.background) // your primary color here
        appearance.shadowColor = UIColor(Color.background)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.background)
        tabAppearance.shadowColor = UIColor(Color.background) // border color
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.Primary)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.Primary)]

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        
        UINavigationBar.appearance().tintColor = UIColor(Color.Primary)
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab){
            DailyView(viewModel: DailyViewModel())
                .tabItem{
                    Label("Daily", systemImage: "sun.min")
                }
                .tag(0)
            WeeklyView(viewModel: WeeklyViewModel())
                .tabItem{
                    Label("Weekly", systemImage: "calendar")
                }
                .tag(1)
            HabitManagementView(viewModel: HabitManagementViewModel())
                .tabItem{
                    Label("Habit Management", systemImage: "book")
                }
                .tag(2)
        }
    }
}


#Preview {
    ContentView()
}

