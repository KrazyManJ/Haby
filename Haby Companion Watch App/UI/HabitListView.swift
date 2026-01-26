import SwiftUI

struct HabitListView: View {
    
    @State private var viewModel: HabitListViewModel
    
    init(filterType: InternalHabitCategory) {
        self.viewModel = .init(filterType: filterType)
    }
    
    var title: String {
        switch viewModel.state.filterType {
        case .Numeric:
            "Goal habits"
        case .Timer:
            "Upcoming habits"
        }
    }
    
    var todayMinutes = Date().hourAndMinutesToMinutesTimestamp
    
    var habitsToDo: [HabitDefinition] {
        viewModel.state.habits.filter { habit in
            let isExpired = switch habit.data {
            case .Deadline(let data): todayMinutes >= data.minutesOfCompletionInFrequency
            case .OnTime(let data): todayMinutes >= data.minutesOfCompletionInFrequency
            default: true
            }
            
            let record = viewModel.state.records.first { $0.habitDefinition.id == habit.id }
            if let record = record {
                return !record.isSatisfied && !isExpired
            }
            
            else {
                return !isExpired
            }
        }
    }
    
    @State private var selectedHabit: HabitDefinition?
    
    func getRecord(for habit: HabitDefinition) -> HabitRecord? {
        return viewModel.state.records.first { $0.habitDefinition.id == habit.id }
    }
    
    var body: some View {
        NavigationStack {
            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
            ScrollView {
                VStack {
                    if viewModel.state.habits.isEmpty {
                        Text("No habits received yet. \nOpen iPhone app to sync")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(habitsToDo) { habit in
                            HabitWatchRow(habit: habit, record: getRecord(for: habit))
                                .onTapGesture { selectedHabit = habit }
                        }
                        
                        if habitsToDo.isEmpty {
                            Text("All done for now!")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }
                    }
                }
                .sheet(item: $selectedHabit) { habit in
                    NavigationStack {
                        if case .Amount = habit.data {
                            AmountHabitDetailView(viewModel: $viewModel, habit: habit)
                        } else {
                            TimeHabitDetailView(viewModel: $viewModel, habit: habit)
                        }
                    }
                }
            }
        }
        .padding([.horizontal])
        .background(.backgroundPrimary)
        .onAppear {
            viewModel.fetchHabits()
        }
        .onReceive(NotificationCenter.default.publisher(for: .reloadHabits)) { _ in
            print("🔄 reloading data from Watch update...")
            viewModel.fetchHabits()
        }
    }
}

#Preview {
    HabitListView(filterType: .Timer)
}
