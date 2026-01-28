import SwiftUI

struct HabitDetailHeader: View {
    let habit: HabitDefinition
    let status: HabitStatusHelper
    let isChecked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: habit.icon)
                .font(.title)
                .foregroundColor(Colors.TextSecondary)
            
            Text(habit.name)
                .font(.headline)
            
            if case .Amount = habit.data {
                Text(status.progressString)
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text(status.requirementString)
                    .font(.caption)
                    .foregroundColor(status.isOverdue ? .red : .gray)
            }
        }
        .padding(.top)
    }
}
