import SwiftUI

struct UpcomingHabitView: View {
    let habit: HabitDefinition?
    var body: some View {
        ZStack{
            RadialGradient(
                gradient: Gradient(colors: [.brandPrimary.opacity(0.3), .clear]),
               center: .center,
               startRadius: 5,
               endRadius: 65
           )
            VStack {
                if (habit != nil) {
                    Image(systemName: habit?.icon ?? "star.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(.textPrimary)
                    Text(habit?.name ?? "Cannot load habit name")
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

