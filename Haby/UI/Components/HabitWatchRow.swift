import SwiftUI

struct HabitWatchRow: View {
    var habit: HabitDefinition
    
    var requirementString: String
    
    init(habit: HabitDefinition) {
        self.habit = habit
        if habit.type != .Amount {
            if let timestamp = habit.targetTimestamp {
                let targetDate = Date.fromMinutesTimestamp(timestamp: timestamp)
                
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                
                self.requirementString = formatter.localizedString(for: targetDate, relativeTo: Date())
            } else {
                requirementString = ""
            }
        } else {
            if let amount = habit.targetValue,
               let unit  = habit.targetValueUnit?.abbreviation {
                self.requirementString = "\(amount.rounded(.towardZero)) \(unit)"
            } else {
                requirementString = ""
            }
        }
    }
    
    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: habit.icon)
                        Text(habit.name)
                    }
                    HStack {
                        Text("\(habit.frequency.name) • \(habit.type.name)")
                            .font(.footnote)
                    }
                }
                Spacer()
                if habit.type != .Amount {
                    Text(requirementString).font(.footnote)
                } else {
                    Text("value/\(requirementString)").font(.footnote)
                }
            }
            .padding()
        }
    }
}

#Preview {
    HabitWatchRow(habit: HabitDefinition(
        name: "test",
        icon: "star.fill",
        creationDate: .now,
        type: .Deadline,
        frequency: .Daily,
        targetTimestamp: Date().hourAndMinutesToMinutesTimestamp,
        data: .Deadline(data: .init(frequency: .Daily, minutesOfCompletionInFrequency: Date().hourAndMinutesToMinutesTimestamp))
    ))
}
