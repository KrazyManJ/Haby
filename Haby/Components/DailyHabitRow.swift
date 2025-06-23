import SwiftUI

struct DailyHabitRow: View {
    @Binding var viewModel: DailyViewModel
    @State private var showConfirmation = false
    var habit: HabitDefinition
    private var isCheckedBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                viewModel.state.habitRecords.contains(where: { $0.habitDefinition.id == habit.id })
            },
            set: { value in
                if value {
                    viewModel.checkHabit(habit: habit)
                } else {
                    showConfirmation = true
                }
            }
        )
    }
    
    var isChecked: Bool {
        isCheckedBinding.wrappedValue
    }
    
    var isValid: Bool {
        if isCheckedBinding.wrappedValue {
            guard let record = viewModel.state.habitRecords.first(where: { $0.habitDefinition.id == habit.id }) else {
                return false
            }
            return record.isCompleted
        }
        else {
            var timestamp = Date().hourAndMinutesToMinutesTimestamp
            if habit.frequency == .Weekly {
                timestamp += WeekDay.getTodayWeekDay().toTimestamp
            }
            return habit.canBeCheckedInTimestamp(timestamp: timestamp)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment:.bottom) {
                Rectangle()
                    .fill(isChecked || !isValid ? Color.backgroundDisabled : Color.Primary)
                    .frame(width: 8, height: 40)
                    .padding([.leading],48)
                Text(String(format: "%02d:%02d", habit.targetTimestamp! / 60 % 24, habit.targetTimestamp! % 60))
                    .padding([.bottom],8)
                    .font(.system(.footnote))
            }
            HStack{
                let img = Image(systemName: habit.icon)
                if (isChecked && isValid) {
                    img.foregroundStyle(Color.textDisabled)
                }
                else {
                    img
                }
                
                Text(habit.name)
                    .foregroundStyle(Color.TextLight)
                    .bold()
                Spacer()
                CheckBox(isOn: isCheckedBinding,isInvalid: !isValid)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isChecked || !isValid ? Color.backgroundDisabled : Color.Primary)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
            .foregroundStyle(
                isValid ? Color.Secondary : (habit.type == .OnTime && !isChecked ? Color.textDisabled : .red )
            )
        }
        .confirmationDialog("Are you sure you want to uncheck this habit? This action loses your current stage of habit.", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Uncheck", role: .destructive) {
                viewModel.checkHabit(habit: habit)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    
}
