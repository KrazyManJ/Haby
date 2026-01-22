import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView(selection: .constant(1)) {
            HabitListView(filterType: .time)
                .tag(1)
            HabitListView(filterType: .amount)
                .tag(2)
      }
    }
}

#Preview {
    ContentView()
}
