
import SwiftUI

struct WeekTable: View {
    @Binding var viewModel: WeeklyViewModel
    
    @State private var showingConfirmation = false
    @State private var habitToUncheck: HabitDefinition?
    @State private var dateToUncheck: Date?
    
    private let weekDates = Calendar.currentWithMondayAsSWeekStartDay.currentWeekDates()
    
    private var tableHeader: some View {
        HStack {
            Color.clear.frame(width: 30)
            ForEach(weekDates, id: \.self) { date in
                VStack {
                    Text(date.shortWeekday.uppercased())
                        .font(.caption)
                        .if(Date().weekday == date.weekday) {
                            $0
                                .foregroundStyle(.brandPrimary)
                                .bold()
                        }
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .frame(width: 35)
            }
        }
        .font(.headline)
        .padding(.bottom, 4)
    }
    
    private var tableBody: some View {
        
        ForEach(viewModel.state.habits) { habit in
            HStack {
                Image(systemName: habit.icon)
                    .frame(width: 30, alignment: .leading)
                
                ForEach(weekDates, id: \.self) { date in
                    
                    let record = viewModel.state.habitRecords.first { $0.habitDefinition.id == habit.id }
                    var checked: Bool {
                        if let record = record {
                            return record.data.details.date.weekday == date.weekday
                        }
                        return false
                    }
                    var enabled: Bool {
                        return date.onlyDate == Date().onlyDate || checked
                    }
                    var isValid: Bool {
                        
                        var timestamp: Int?
                        switch habit.data {
                        case .Deadline(let data):
                            timestamp = data.minutesOfCompletionInFrequency
                        case .OnTime(let data):
                            timestamp = data.minutesOfCompletionInFrequency
                        default:
                            break
                        }
                        
                        var canCompleteThatDay: Bool {
                            if Date().weekday == date.weekday {
                                return Date().minutesFromStartOfWeek() <= (timestamp ?? 0)
                            }
                            return date.minutesFromStartOfWeek() <= (timestamp ?? 0)
                        }
                        if let record = record {
                            return record.data.details.date.weekday == date.weekday ? record.isSatisfied : canCompleteThatDay
                        }
                        
                        return canCompleteThatDay
                    }
        
                    
                    let checkBinding = Binding<Bool>(
                        get: { checked },
                        set: { newValue in
                            if checked {
                                habitToUncheck = habit
                                dateToUncheck = date
                                showingConfirmation = true
                            }
                            else if record == nil {
                                viewModel.setHabit(habit, checked: true, on: Date())
                            }
                        }
                    )
                    
                    CircleCheck(isOn: checkBinding, isInvalid: !isValid)
                        .frame(width: 35, alignment: .center)
                        .disabled(!enabled)
//                            let isChecked = viewModel.isHabitChecked(habit: habit, on: date)
//                            let isValid = isHabitValid(habit: habit, date: date)
//                            let selectedDate = viewModel.selectedDates[habit.id]
//                            let isSelectedDay = selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: date)
//                            let isDisabled = selectedDate != nil && !isSelectedDay
//
//                            CircleCheck(
//                                isOn: Binding<Bool>(
//                                    get: { isChecked },
//                                    set: { newValue in
//                                        if isChecked {
//                                            habitToUncheck = habit
//                                            dateToUncheck = date
//                                            showingConfirmation = true
//                                        } else {
//                                            viewModel.setHabit(habit, checked: true, on: date)
//                                            viewModel.selectedDates[habit.id] = date
//                                        }
//                                    }
//                                ),
//                                isInvalid: !isValid || isDisabled
//                            )
//                            .frame(width: 35, alignment: .center)
//                            .disabled(isDisabled)
//                            .if(isChecked) {
//                                $0.foregroundStyle(isValid ? Colors.Primary : Colors.Destructive)
//                            }
                }
            }
            .padding(.top, 10)
        }
    }
    
    var body: some View {
        Card {
            VStack(alignment: .center, spacing: 8) {
                tableHeader
                tableBody
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
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }   
}

#Preview {
    WeeklyView()
        .preferredColorScheme(.dark)
}
