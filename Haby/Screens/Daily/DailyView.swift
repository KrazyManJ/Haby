
import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {

            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 25, height: 25)
                .cornerRadius(5.0)
                .overlay {
                    if (configuration.isOn){
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }

            configuration.label
        }
    }
}

struct DailyHabitRow: View {
    @Binding var viewModel: DailyViewModel
    @State private var showConfirmation = false
    var habit: HabitDefinition
    
    var body: some View {
        HStack{
            Text(habit.name)
            Spacer()
            Toggle(isOn: Binding(
                get: {
                    viewModel.state.habitRecords.first { $0.habitDefinition.id == habit.id} != nil
                },
                set: { value in
                    if !value {
                        showConfirmation = true
                    }
                    else { viewModel.checkHabit(habit: habit) }
                }
            )){}
            .toggleStyle(CheckboxToggleStyle())
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

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    @State private var checked: Bool = false
    
    init(viewModel: DailyViewModel) {
        self.viewModel = viewModel
        viewModel.getTodayMood()
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    ForEach(viewModel.state.habits) { habit in
                        DailyHabitRow(
                            viewModel: $viewModel, habit: habit
                        )
                    }
                }
                Picker("Track today's mood", selection: Binding(
                    get: {
                        viewModel.state.todayMoodData.mood
                    },
                    set: {
                        viewModel.state.todayMoodData.mood = $0
                        viewModel.updateMood(mood: $0)
                    }
                )) {
                    ForEach(Mood.allCases, id: \.self) { value in
                        Text(value.emoji).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Text("Value: \(String(describing: viewModel.state.todayMoodData.mood))")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Daily Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    NavigationLink(destination: OverviewView()) {
                        Text("Streak")
                    }
                }
            }.onAppear {
                if !viewModel.isTodayMoodSaved() {
                    viewModel.updateMood(mood: .Neutral)
                }
                viewModel.getTodayHabits()
            }
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
