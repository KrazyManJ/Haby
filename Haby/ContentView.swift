
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
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

