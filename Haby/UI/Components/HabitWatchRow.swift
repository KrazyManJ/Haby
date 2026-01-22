import SwiftUI

struct HabitWatchRow: View {
    let habit: HabitDefinition
    let record: HabitRecord?
    private let status: HabitStatusHelper
        
    init(habit: HabitDefinition, record: HabitRecord?) {
        self.habit = habit
        self.record = record
        self.status = HabitStatusHelper(habit: habit, record: record)
    }
    
    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: habit.icon).font(.caption2)
                        Text(habit.name)
                            .font(.caption2)
                    }
                    HStack {
                        // todo if amount dont show type name
                        if (habit.data.type != .Amount){
                            Text("\(habit.data.details.frequency.name) • \(habit.data.type.name)")
                                .font(.footnote)
                        } else {
                            Text(habit.data.details.frequency.name)
                                .font(.footnote)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if case .Amount = habit.data {
                        Text(status.progressString)
                            .font(.footnote)
                            .foregroundColor(Colors.TextSecondary)
                    }
                    else {
                        Text(status.requirementString)
                            .font(.footnote)
                            .foregroundColor(status.isOverdue ? Colors.Destructive : Colors.TextSecondary)
                    }
                }
            }
            .padding()
        }
    }
}
