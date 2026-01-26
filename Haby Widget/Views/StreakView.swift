import SwiftUI

struct StreakView: View {
    let streak: Int
    var body: some View {
        ZStack{
            RadialGradient(
                gradient: Gradient(colors: [.brandPrimary.opacity(0.3), .clear]),
               center: .center,
               startRadius: 5,
               endRadius: 65
           )
            VStack {
                Image(systemName: "flame")
                    .foregroundStyle(.textPrimary)
                    .font(.system(size: 55))
                Text("Your streak is...")
                    .foregroundStyle(.textPrimary)
                    .font(.footnote)
                Text("\(streak) Days")
                    .foregroundStyle(.textPrimary)
                    .font(.title)
            }
        }
    }
}
