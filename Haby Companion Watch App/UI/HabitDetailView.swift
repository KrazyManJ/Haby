import SwiftUI

struct HabitDetailView: View {
    var habit: HabitDefinition
//    @Environment(\.dismiss) var dismiss
    
    var requirementString: String
    
    init(/*isViewPresented: Binding<Bool>,*/ habit: HabitDefinition) {
        //self._isViewPresented = isViewPresented
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
        VStack(alignment: .center) {
            Image(systemName: habit.icon).font(.title)
            Text(habit.name)
            if (habit.type != .Amount){
                Text(requirementString)
            } else {
                Text("value/\(requirementString)")
            }
            Button("Check/Add progress"){}
        }
    }
}
