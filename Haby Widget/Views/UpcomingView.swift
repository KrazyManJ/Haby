import SwiftUI

struct UpcomingHabitView: View {
    let habits: [HabitDefinition]
    var body: some View {
        ZStack{
            RadialGradient(
                gradient: Gradient(colors: [.brandPrimary.opacity(0.3), .clear]),
               center: .center,
               startRadius: 5,
               endRadius: 65
           )
            VStack {
                if let next = habits.first {
                    Image(systemName: next.icon)
                        .font(.system(size: 55))
                        .foregroundStyle(.textPrimary)
                    Text(next.name)
                        .font(.title)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                }
                Text("Your nearest habit")
                    .font(.footnote)
                    .foregroundStyle(.textPrimary)
            }
        }
    }
}

