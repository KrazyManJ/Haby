
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    @State private var checked: Bool = false
    private var mood: Binding<Mood>
    
    @ObservedObject var sessionManager = PhoneSessionManager.shared
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.mainTabViewRefresh) var performMainTabViewRefresh
    
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
    
    private var timerHabits: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Timeline(variant: .FadeIn)
            ForEach(viewModel.state.habits.filter { $0.data.type != .Amount } ) { habit in
                let record = viewModel.state.habitRecords.first { $0.habitDefinition.id == habit.id }
                
                TimerHabitRow(
                    habit: habit,
                    isChecked: record != nil,
                    isValid: record?.isSatisfied ?? true
                ) {
                    viewModel.checkHabit(habit: habit)
                    refreshData()
                    performMainTabViewRefresh()
                }
            }
            Timeline(variant: .FadeOut)
        }
        .padding([.horizontal])
    }
    
    private var goalHabits: some View {
        Card {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.state.amountHabits) { habit in
                    let record = viewModel.state.habitRecords.first { $0.habitDefinition.id == habit.id }
                    
                    var amount: Float {
                        switch record?.data {
                        case .Amount(let data): data.value
                        default: 0.0
                        }
                    }
                    
                    GoalHabitRow(
                        habit: habit,
                        currentAmount: amount
                    ) { addValue in
                        viewModel.addToAmountHabit(habit: habit, addedAmount: addValue)
                        performMainTabViewRefresh()
                    }
                }
            }
            .padding()
        }
        .padding()
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Subtitle("Daily timeline")
                timerHabits
                Subtitle("Goals")
                goalHabits
            }
            VStack {
                Subtitle("Hod did you feel?")
                MoodPickerView(selectedMood: mood)
                    .padding([.horizontal])
                    .padding([.bottom], 32)
            }
        }
            .background(Colors.BackgroundPrimary)
            .onAppear {
                if !viewModel.isTodayMoodSaved() {
                    viewModel.updateMood(mood: .Neutral)
                }
                refreshData()
                sessionManager.syncAllHabitsToWatch()
                viewModel.askForNotificationPermission()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    print("App returned to foreground. Refreshing data...")
                    refreshData()
                }
            }
            .onChange(of: viewModel.state.habits) { oldHabits, newHabits in
                if !newHabits.isEmpty {
                    print("📤 Habits loaded. Syncing to Watch...")
                    sessionManager.syncAllHabitsToWatch()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .reloadHabits)) { _ in
                print("🔄 reloading data from Watch update...")
                viewModel.getTodayHabits()
            }
    }
    
    func refreshData() {
        viewModel.getTodayHabits()
        Task {
            await viewModel.loadHealthDataForToday()
            viewModel.syncHealthDataToHabits()
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
