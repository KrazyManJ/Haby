import SwiftUI

struct DailyHabitRow: View {
    @Binding var viewModel: DailyViewModel
    @State private var showConfirmation = false
    var habit: HabitDefinition
    
    var expiredTick: Bool {
            guard let record = viewModel.state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }),
                  let targetTimestamp = habit.targetTimestamp,
                  let timestamp = record.timestamp else {
                return false
            }
            return timestamp <= targetTimestamp
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment:.bottom) {
                Rectangle()
                    .fill(Color.Primary)
                    .frame(width: 8, height: 40)
                    .padding([.leading],48)
                Text(String(format: "%02d:%02d", habit.targetTimestamp! / 60 % 24, habit.targetTimestamp! % 60))
                    .padding([.bottom],8)
                    .font(.system(.footnote))
            }
            HStack{
                Image(systemName: habit.icon)
                Text(habit.name)
                    .foregroundStyle(Color.TextLight)
                    .bold()
                if let record = viewModel.state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) {
                    Text("\(expiredTick)")
                }
                Spacer()
                CheckBox(isOn: Binding(
                    get: {
                        viewModel.state.habitRecords.first { $0.habitDefinition.id == habit.id} != nil
                    },
                    set: { value in
                        if !value { showConfirmation = true }
                        else { viewModel.checkHabit(habit: habit) }
                    }
                ))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.Primary)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
            .foregroundStyle(Color.Secondary)
        }
        .confirmationDialog("Are you sure you want to uncheck this habit? This action loses your current stage of habit.", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Uncheck", role: .destructive) {
                viewModel.checkHabit(habit: habit)
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}

#Preview {
    
}
