import SwiftUI

enum HabitFilterType {
    case time
    case amount
}

struct HabitListView: View {
    let filterType: HabitFilterType
    @State private var selectedHabit: HabitDefinition?
    
    @ObservedObject var sessionManager = WatchSessionManager.shared
    var body: some View {
        NavigationStack {
            Text(filterType == .time ? "Upcoming habits" : "Goal habits")
                .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            VStack {
                if sessionManager.habits.isEmpty {
                    Text("No habits received yet. \nOpen iPhone app to sync")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    let habitsToShow = sessionManager.habits.filter { $0.type == (filterType == .time ? .Deadline : .Amount) };   ForEach(habitsToShow) { habit in
                        //Text(habit.name)
                        HabitWatchRow(habit: habit)
                        .onTapGesture {
                            selectedHabit = habit
                        }
                    }
                }
            }
            .sheet(item: $selectedHabit) { habit in
                NavigationStack {
                    HabitDetailView(habit: habit)
                }
            }
//            .sheet(item: $habitToEdit) { habit in
//                NavigationStack {
//                    HabitDetailView(
//                        isViewPresented: Binding(
//                            get: { habitToEdit != nil },
//                            set: { isPresented in
//                                if !isPresented { habitToEdit = nil }
//                            }
//                        ),
//                        habit: habit,
//                    )
//                }
//            }
        }
    }
}

#Preview {
    HabitListView(filterType: .time)
}
