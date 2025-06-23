
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    @State private var checked: Bool = false
    private var mood: Binding<Mood>
    
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
                    
                    if !viewModel.state.amountHabits.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.state.amountHabits) { habit in
                                DailyGoalProgressBar(
                                    viewModel: $viewModel, habit: habit
                                )
                                .padding(8)
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.Secondary)
                        )
                        .padding()
                    }
                }
                MoodPickerView(selectedMood: mood).padding()
               
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Daily Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    NavigationLink(destination: OverviewView()) {
                        Button("Streak", systemImage: "flame"){}
                            .tint(.orange)
                    }
                }
            }
            .onAppear {
                if !viewModel.isTodayMoodSaved() {
                    viewModel.updateMood(mood: .Neutral)
                }
                viewModel.getTodayHabits()
                Task {
                    await viewModel.loadStepData()
                }
            }
            .background(Color.Background)
//            .alert("Unable to load step data from HealthKit", isPresented: $viewModel.showHealthKitError) {
//                Button("OK", role: .cancel) {}
//            }
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
