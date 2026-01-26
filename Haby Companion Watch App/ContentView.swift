import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HabitListView(filterType: .Timer)
                .tag(1)
            HabitListView(filterType: .Numeric)
                .tag(2)
        }
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
