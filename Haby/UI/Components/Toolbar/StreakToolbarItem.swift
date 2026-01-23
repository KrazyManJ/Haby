import SwiftUI

struct StreakToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                OverviewView()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.brandPrimary) // Make the flame orange
                    
                    Text("12") // Your streak number
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
    }
}
