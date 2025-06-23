
import SwiftUI

struct HabitRow: View {
    var habit: HabitDefinition
    
    var requirementString: String
    
    init(habit: HabitDefinition) {
        self.habit = habit
        if habit.type != .Amount {
            if let timestamp = habit.targetTimestamp {
                self.requirementString = String(format: "%02d:%02d", timestamp / 60 % 24, timestamp % 60)
            } else {
                requirementString = ""
            }
        } else {
            if let amount = habit.targetValue, let unit  = habit.targetValueUnit?.abbreviation {
                self.requirementString = "\(amount) \(unit)"
            } else {
                requirementString = ""
            }
        }
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: habit.icon)
                    Text(habit.name)
                }
                Text("\(habit.type.name) • \(habit.frequency.name) • \(requirementString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    //HabitRow()
}
