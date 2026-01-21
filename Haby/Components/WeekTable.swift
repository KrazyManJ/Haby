
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
        Card {
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Color.clear.frame(width: 30)
                    ForEach(weekDates, id: \.self) { date in
                        VStack {
                            Text(date.shortWeekday.uppercased())
                                .font(.caption)
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 35)
                    }
                }
                .font(.headline)
                .padding(.bottom, 4)
                
                ForEach(viewModel.state.habits) { habit in
                    HStack {
                        Image(systemName: habit.icon)
                            .frame(width: 30, alignment: .leading)
                        
                        ForEach(weekDates, id: \.self) { date in
                            let isChecked = viewModel.isHabitChecked(habit: habit, on: date)
                            let isValid = isHabitValid(habit: habit, date: date)
                            let selectedDate = viewModel.selectedDates[habit.id]
                            let isDisabled = selectedDate != nil && selectedDate != date
                            
                            CircleCheck(
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
                            .frame(width: 35, alignment: .center)
                            .disabled(isDisabled)
                            .if(isChecked) {
                                $0.foregroundStyle(isValid ? Colors.Primary : Colors.Destructive)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .confirmationDialog(
            "Are you sure you want to uncheck this habit? This action loses your current stage of habit.",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
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

#Preview {
//    WeekTable(viewModel: WeeklyViewModel(), showingConfirmation: false, habitToUncheck: <#T##HabitDefinition?#>, dateToUncheck: <#T##Date?#>)
}