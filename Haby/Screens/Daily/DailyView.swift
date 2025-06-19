
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    @State private var checked: Bool = false
    private var mood: Binding<Mood>
    // todo finish step goal progress bar
    let stepGoal = 10000.0
    
    init(viewModel: DailyViewModel) {
        self.viewModel = viewModel
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.Primary)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.Secondary)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 24),
        ], for: .normal)
        viewModel.getTodayMood()
        mood = Binding(
            get: {
                viewModel.state.todayMoodData.mood
            },
            set: {
                viewModel.state.todayMoodData.mood = $0
                viewModel.updateMood(mood: $0)
            }
        )
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.state.habits.filter { $0.type != .Amount}) { habit in
                            DailyHabitRow(
                                viewModel: $viewModel, habit: habit
                            )
                        }
                        Spacer(minLength: 0)
                    }.padding()
                    
                    // step progress delete later
                    //StepProgressBar(steps: viewModel.stepsToday, goal: stepGoal)
                    //   .frame(height: 20)
                    //   .padding(.horizontal)
                    
                    // amount habits
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.state.amountHabits) { habit in
                            DailyGoalProgressBar(
                                viewModel: $viewModel, habit: habit, currentAmount: 3.1
                            )
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.Secondary)
                    )
                    .padding()
                }
                MoodPickerView(selectedMood: mood).padding()
               
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Daily Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    NavigationLink(destination: OverviewView()) {
                        Button("Streak", systemImage: "flame"){}
                    }
                }
            }.onAppear {
                if !viewModel.isTodayMoodSaved() {
                    viewModel.updateMood(mood: .Neutral)
                }
                viewModel.getTodayHabits()
                Task {
                    await viewModel.loadStepData()
                }
            }.background(Color.Background)
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
