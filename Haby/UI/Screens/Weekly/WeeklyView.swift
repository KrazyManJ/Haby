

import SwiftUI

struct WeeklyView: View {
    @State private var viewModel: WeeklyViewModel
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.mainTabViewRefresh) var performMainTabViewRefresh
    
    init(viewModel: WeeklyViewModel = WeeklyViewModel()) {
        self.viewModel = viewModel
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
                        viewModel.addToWeeklyAmountHabit(habit: habit, addedAmount: addValue)
                        performMainTabViewRefresh()
                    }
                }
            }
            .padding()
        }
        .padding()
    }
    
    var body: some View {
        VStack{
            ScrollView {
                Subtitle("Week table")
                if !viewModel.state.habits.filter({ $0.data.type != .Amount }).isEmpty {
                    
                    WeekTable(viewModel: $viewModel)
                        .padding()
                }  else {
                    Text("No weekly habits!").italic().foregroundColor(.gray)
                        .padding(.vertical,32)
                }
                
                Subtitle("Goals")
                if !viewModel.state.amountHabits.isEmpty {
                    goalHabits
                }  else {
                    Text("No goal habits for this week!")
                        .italic().foregroundColor(Color.gray).padding(.vertical,32)
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                print("App returned to foreground. Refreshing data...")
                viewModel.refreshData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .reloadHabits)) { _ in
            print("🔄 reloading data from Watch update...")
            viewModel.getWeekHabits()
        }
        .background(Colors.BackgroundPrimary)
    }
}

#Preview {
    WeeklyView()
        .preferredColorScheme(.dark)
        .foregroundStyle(.textPrimary)
}
