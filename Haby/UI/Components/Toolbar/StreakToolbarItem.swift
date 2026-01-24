import SwiftUI

struct StreakToolbarItem: ToolbarContent {
    
    let streak: Int
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                OverviewView()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(streak > 0 ? .brandPrimary : .textSecondary)
                    Text(String(streak))
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
    }
}
