
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
                }
                MoodPickerView(selectedMood: mood).padding()
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
            }.background(Color.Background)
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
