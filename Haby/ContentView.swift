
import SwiftUI

struct ContentView: View {
    
    private func initNavigationStyling() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.BackgroundPrimary.ui
        appearance.shadowColor = Colors.BackgroundPrimary.ui
        appearance.titleTextAttributes = [.foregroundColor: Colors.TextPrimary.ui]
        appearance.largeTitleTextAttributes = [.foregroundColor: Colors.TextPrimary.ui]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = Colors.BackgroundPrimary.ui
        tabAppearance.shadowColor = nil
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some View {
        MainTabView()
            .preferredColorScheme(.dark)
            .foregroundStyle(Colors.TextPrimary)
            .background(Colors.BackgroundPrimary)
            .onAppear { initNavigationStyling() }
    }
}


#Preview {
    ContentView()
}
