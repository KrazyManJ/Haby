
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    @State private var checked: Bool = false
    private var mood: Binding<Mood>
    
    init(viewModel: DailyViewModel = DailyViewModel()) {
        self.viewModel = viewModel
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
            VStack(spacing: 0) {
                ScrollView {
                    Text("Daily timeline")
                        .padding(.horizontal, 32)
                        .padding([.top], 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3).bold()
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.state.habits.filter { $0.type != .Amount}) { habit in
                            DailyHabitRow(
                                viewModel: $viewModel, habit: habit
                            )
                        }
                        if viewModel.state.habits.filter({ $0.type != .Amount}).isEmpty {
                            Text("No habits in daily timeline for today!").italic().foregroundColor(Color.gray).padding(.vertical,32)
                        }
                        Spacer(minLength: 0)
                    }.padding()
                    
                    Text("Goals")
                        .padding(.horizontal, 32)
                        .padding([.top], 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3).bold()
                    if !viewModel.state.amountHabits.isEmpty {
                        Card {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.state.amountHabits) { habit in
                                    DailyGoalProgressBar(
                                        viewModel: $viewModel, habit: habit
                                    )
                                    .padding(8)
                                }
                            }.padding()
                        }
                        .frame(minHeight: 100)
                        .padding()
                    } else {
                        Text("No goal habits for today!")
                            .italic()
                            .foregroundColor(Color.gray)
                            .padding(.vertical,32)
                    }
                }
                Text("Mood")
                    .padding(.horizontal, 32)
                    .padding([.top], 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title3).bold()
                MoodPickerView(selectedMood: mood).padding()
               
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Daily Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    NavigationLink(destination: OverviewView()) {
                        Button("Streak", systemImage: "flame"){
                            
                        }
                    }
                    .tint(Color.orange)
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
            .background(Colors.BackgroundPrimary)
            .alert("Unable to load step data from HealthKit", isPresented: $viewModel.showHealthKitError) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
