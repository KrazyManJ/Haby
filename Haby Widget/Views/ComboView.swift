import SwiftUI

struct ComboView: View {
    let habits: [HabitDefinition]
    let streak: Int
    var body: some View {
        HStack{
            StreakView(streak: streak).frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 8) {
                if (habits.isEmpty){
                    Text("You have no upcoming habits")
                        .foregroundStyle(.textPrimary)
                        .font(.caption)
                } else {
                    ForEach(habits.prefix(3)) { habit in
                        Card {
                            HStack{
                                Image(systemName: habit.icon)
                                    .foregroundStyle(.textPrimary)
                                    .font(.caption)
                                Text(habit.name)
                                    .foregroundStyle(.textPrimary)
                                    .lineLimit(1)
                                    .font(.caption)
                                Spacer()
                            }
                            .padding(4)
                        }
                        .padding(8)
                        .background(.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

