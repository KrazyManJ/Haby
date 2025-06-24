
import SwiftUI

struct WeekTable: View {
    @Binding var viewModel: WeeklyViewModel
    @State private var showingConfirmation = false
    @State private var habitToUncheck: HabitDefinition?
    @State private var dateToUncheck: Date?
    
    private let weekDates = Calendar.current.currentWeekDates()
    
    func isHabitValid(habit: HabitDefinition, date: Date) -> Bool {
        var timestamp = date.hourAndMinutesToMinutesTimestamp
        if habit.frequency == .Weekly {
            timestamp += WeekDay(from: date).toTimestamp
        }
        return habit.canBeCheckedInTimestamp(timestamp: timestamp)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                ForEach(weekDates, id: \.self) { date in
                    VStack {
                        Text(date.shortWeekday)
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .font(.headline)
            .padding(.bottom, 4)
            
            ForEach(viewModel.state.habits) { habit in
                HStack {
                    Image(systemName: habit.icon)
                        .frame(width: 50, alignment: .leading)
                    
                    ForEach(weekDates, id: \.self) { date in
                        //let isInvalid = date > Date().onlyDate
                        let isChecked = viewModel.isHabitChecked(habit: habit, on: date)
                        let isValid = isHabitValid(habit: habit, date: date)
                        let selectedDate = viewModel.selectedDates[habit.id]
                        let isDisabled = selectedDate != nil && selectedDate != date
                        
                        CheckBox(
                            isOn: Binding<Bool>(
                                get: { isChecked },
                                set: { newValue in
                                    if isChecked {
                                        habitToUncheck = habit
                                        dateToUncheck = date
                                        showingConfirmation = true
                                    } else {
                                        viewModel.setHabit(habit, checked: true, on: date)
                                        viewModel.selectedDates[habit.id] = date
                                    }
                                }
                            ),
                            isInvalid: !isValid || isDisabled
                        )
                        .padding(.trailing, 10)
                        .disabled(isDisabled)
                        .foregroundStyle(
                            isChecked ? (isValid ? Color.Primary : .red) : .primary
                        )
                        
                    }
                    
                }
            }
        }
            .frame(minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.Secondary)
            )
            .padding()
            .confirmationDialog("Are you sure you want to uncheck this habit? This action loses your current stage of habit.", isPresented: $showingConfirmation, titleVisibility: .visible) {
                Button("Uncheck", role: .destructive) {
                    if let habit = habitToUncheck, let date = dateToUncheck {
                        viewModel.setHabit(habit, checked: false, on: date)
                        viewModel.selectedDates[habit.id] = nil
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        
    }
}
