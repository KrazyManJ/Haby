
import SwiftUI

struct DailyGoalProgressBar: View {
    @Binding var viewModel: DailyViewModel
    var habit: HabitDefinition
    var currentAmount: Float
    //var goal: Double

    var progress: Float {
        min(currentAmount / habit.targetValue!, 1.0)
    }
    
    var progressColor: Color {
            switch progress {
            case 0..<0.5: return .red
            case 0.5..<1.0: return .orange
            default: return .green
            }
        }
    
    var body: some View {
        VStack{
            HStack{
                Text(habit.name)
                Spacer()
                Text("\(Int(currentAmount)) / \(Int(habit.targetValue!)) \(habit.targetValueUnit!.abbreviation)")
                //Text("habit progress")
                Image(systemName: "plus")
            }
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(progressColor)
                    .frame(width: geo.size.width * CGFloat(progress), height: 10)
                    .animation(.easeInOut, value: progress)
            }
        }
        .padding(10)
        }
        
    }
}

#Preview {
    //DailyGoalProgressBar(currentAmount: <#T##Double#>, goal: <#T##Double#>)
}
