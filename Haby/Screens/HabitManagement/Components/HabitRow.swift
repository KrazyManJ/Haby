
import SwiftUI

struct HabitRow: View {
    var habit: HabitDefinition
    var time: String
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: habit.icon)
                    Text(habit.name)
                }
                Text("\(habit.type.name) • \(habit.frequency.name) • \(time)")
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
