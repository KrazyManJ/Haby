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
                    .fill(Colors.BackgroundSecondary)
                    .frame(width: 8, height: 40)
                    .padding([.leading],48)
                Text(String(format: "%02d:%02d", habit.targetTimestamp! / 60 % 24, habit.targetTimestamp! % 60))
                    .padding([.bottom],8)
                    .font(.system(.footnote))
            }
            Card {
                HStack {
                    Image(systemName: habit.icon)
                    Text(habit.name)
                        .bold()
                    Spacer()
                    CheckBox(isOn: isCheckedBinding,isInvalid: !isValid)
                }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .if(isChecked && isValid) { $0.foregroundStyle(Colors.Primary) }
                    .if(isChecked && !isValid) { $0.foregroundStyle(Colors.Destructive) }
            }
        }
        .confirmationDialog(
            "Are you sure you want to uncheck this habit? This action loses your current stage of habit.",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Uncheck", role: .destructive) {
                viewModel.checkHabit(habit: habit)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    DailyHabitRow(
        viewModel: .constant(DailyViewModel()),
        habit: HabitDefinition(
            id: UUID(),
            name: "Lol",
            icon: "star",
            creationDate: Date(),
            category: "Wellbeing",
            type: .Deadline,
            frequency: .Daily,
            data: .Deadline(data: .init(frequency: .Daily, minutesOfCompletionInFrequency: 1000))
        )
    )
}
