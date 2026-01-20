import SwiftUI

struct DayDetails: View {
    @Binding var viewModel: OverviewViewModel
    var selectedDateData: SelectedDateData
    
    var moodLabel: String {
        if let mood = selectedDateData.mood {
            return String(describing: mood)
        }
        return "Unknown"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Habits data for: \(selectedDateData.date.toDisplayFormat())").font(.title3)
            Text("Mood: \(selectedDateData.mood?.emoji ?? "🫥") \(moodLabel)")
            ScrollView {
                VStack {
                    if selectedDateData.habitsForDate.isEmpty {
                        Text("No habits data found").italic().foregroundColor(Color.gray)
                        Spacer()
                    }
                    else {
                        ForEach(selectedDateData.habitsForDate) { habit in
                            HStack {
                                Text(habit.name)
                                Spacer()
                                CheckBox(
                                    isOn: .constant(viewModel.wasHabitRecorded(habit: habit, date: selectedDateData.date)),
                                    isInvalid: !viewModel.hasCompletedHabit(habit: habit, date: selectedDateData.date)
                                )
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .padding([.top],32)
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .foregroundStyle(.white)
        .background(Color.backgroundDisabled)
    }
}
