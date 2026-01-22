import SwiftUI

struct TimeHabitDetailView: View {
    let habit: HabitDefinition
    @ObservedObject var sessionManager = WatchSessionManager.shared
    
    @State private var showConfirmation = false
    
    var record: HabitRecord? { sessionManager.records.first(where: { $0.habitDefinition.id == habit.id }) }
    var isChecked: Bool { record != nil }
    var status: HabitStatusHelper { HabitStatusHelper(habit: habit, record: record) }
    
    var body: some View {
            VStack(spacing: 16) {
                HabitDetailHeader(habit: habit, status: status, isChecked: isChecked)
                
                if isChecked {
                    Text("Completed")
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Button {
                        WatchSessionManager.shared.checkHabit(habit)
                    } label: {
                        Text("Check")
                            .fontWeight(.semibold)
                    }
                    .tint(.green)
                }
            }
    }
}
