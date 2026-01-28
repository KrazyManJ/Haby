
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    @State private var checked: Bool = false
    private var mood: Binding<Mood>
    
    @State private var animateContent: Bool = false
    
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
            let filteredHabits = Array(viewModel.state.habits.filter { $0.data.type != .Amount }.enumerated())
            ForEach(filteredHabits, id: \.element.id) { index, habit in
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
                .offset(y: animateContent ? 0 : -50)
                .opacity(animateContent ? 1 : 0)
                .animation(
                    .bouncy(duration: 0.2).delay(Double(index) * 0.05),
                    value: animateContent
                )
            }
            Timeline(variant: .FadeOut)
        }
        .padding([.horizontal])
    }
    
    private var goalHabits: some View {
        Card {
            LazyVStack(spacing: 16) {
                let indexedGoals = Array(viewModel.state.amountHabits.enumerated())
                            
                ForEach(indexedGoals, id: \.element.id) { index, habit in
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
                    .offset(y: animateContent ? 0 : -50)
                    .opacity(animateContent ? 1 : 0)
                    .animation(
                        .bouncy(duration: 0.2).delay(0.2 + (Double(index) * 0.05)), // Starts 0.3s later
                        value: animateContent
                    )
                }
            }
            .padding()
        }
        .padding()
        .offset(y: animateContent ? 0 : -50)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Subtitle("Daily timeline")
                Text("To check the habit please tap and hold the habit row until green background fills entire row.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .padding(8)
                    .padding(.horizontal, 8)
                timerHabits
                Subtitle("Goals")
                goalHabits
            }
            VStack {
                Subtitle("How did you feel today?")
                MoodPickerView(selectedMood: mood)
                    .padding([.horizontal])
                    .padding([.bottom], 32)
            }
        }
            .background(Colors.BackgroundPrimary)
            .onAppear {
                // move to VM
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateContent = true
                }
                viewModel.getTodayHabits()
                viewModel.askForNotificationPermission()
                if !viewModel.isTodayMoodSaved() {
                    viewModel.updateMood(mood: .Neutral)
                }
                Task {
                    //print("🔐 Requesting HealthKit access...")
                    await viewModel.requestMissingPermissions()
                    
                   // print("👂 Starting HealthKit listeners...")
                    viewModel.startListeningToHealthKit()
                    
                  //  print("📥 performing initial data load...")
                    await viewModel.loadHealthDataForToday()
                    await MainActor.run {
                        viewModel.syncHealthDataToHabits()
                    }
                    
                }
                viewModel.syncWithWatch()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    print("App returned to foreground. Refreshing data...")
                    refreshData()
                    viewModel.syncWithWatch()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .reloadHabits)) { _ in
                print("🔄 reloading data from Watch update...")
                viewModel.getTodayHabits()
                viewModel.startListeningToHealthKit()
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
    //DailyView(viewModel: DailyViewModel())
}
