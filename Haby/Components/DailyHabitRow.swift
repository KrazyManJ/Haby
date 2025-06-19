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
        HStack{
            Text(habit.name)
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
        .confirmationDialog("Are you sure you want to uncheck this habit? This action loses your current stage of habit.", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Uncheck", role: .destructive) {
                viewModel.checkHabit(habit: habit)
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}
