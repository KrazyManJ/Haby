
import SwiftUI

struct WeekTable: View {
    @Binding var viewModel: WeeklyViewModel
    private let weekDates = Calendar.current.currentWeekDates()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
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
                       let isInvalid = date > Date().onlyDate
                       CheckBox(
                           isOn: Binding<Bool>(
                               get: {
                                   viewModel.isHabitChecked(habit: habit, on: date)
                               },
                               set: { newValue in
                                   viewModel.setHabit(habit, checked: newValue, on: date)
                               }
                           ),
                           isInvalid: isInvalid
                       )
                       .padding(.trailing, 10)
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
}
}
