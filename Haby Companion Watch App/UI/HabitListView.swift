import SwiftUI

enum HabitFilterType {
    case time
    case amount
}

struct HabitListView: View {
    let filterType: HabitFilterType
    @ObservedObject var sessionManager = WatchSessionManager.shared
    @State private var selectedHabit: HabitDefinition?
    
    func getRecord(for habit: HabitDefinition) -> HabitRecord? {
        // Assuming your records are already filtered for "Today" on the phone side
        // or you filter by date here:
        return sessionManager.records.first { $0.habitDefinition.id == habit.id }
    }
    
    var body: some View {
        NavigationStack {
            Text(filterType == .time ? "Upcoming habits" : "Goal habits")
                .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            ScrollView {
                VStack {
                    if sessionManager.habits.isEmpty {
                        Text("No habits received yet. \nOpen iPhone app to sync")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        let typeFiltered = sessionManager.habits.filter {
                            $0.data.type == (filterType == .time ? .Deadline : .Amount)
                        }
                        let activeHabits = typeFiltered.filter { habit in
                       
                            // 1. Find the record
                            let record = sessionManager.records.first {
                                $0.habitDefinition.id == habit.id
                            }
                            
                            // 2. Decide if we should show it
                            if habit.data.type == .Amount {
                                // Amount Habits: Keep showing until target is reached
                                let status = HabitStatusHelper(habit: habit, record: record)
                                return !status.isCompleted
                            } else {
                                // Time Habits (Deadline/OnTime): Hide if ANY record exists.
                                // Even if it was late (wasDoneCorrectly == false), we don't want it on the "To Do" list.
                                return record == nil
                            }
                        
                        }
                        
                        ForEach(activeHabits) { habit in
                            HabitWatchRow(habit: habit, record: getRecord(for: habit))
//                            HabitWatchRow(habit: habit, record: sessionManager.records.first {
//                                $0.habitDefinition.id == habit.id
//                            })
                                .onTapGesture { selectedHabit = habit }
                        }
                        
                        if activeHabits.isEmpty {
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
                            AmountHabitDetailView(habit: habit)
                        } else {
                            TimeHabitDetailView(habit: habit)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HabitListView(filterType: .time)
}
