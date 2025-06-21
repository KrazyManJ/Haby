
import SwiftUI

struct DailyGoalProgressBar: View {
    @Binding var viewModel: DailyViewModel
    var habit: HabitDefinition
    @State private var currentAmount: Float = 0.0
    @State private var isAddAmountPresented = false
    @State private var amountToAdd: Float = 0.0

    var targetValue: Float {
            habit.targetValue ?? 1.0
        }

    var progress: Float {
        min(currentAmount / targetValue, 1.0)
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
                Image(systemName: habit.icon)
                Text(habit.name)
                Spacer()
                Text("\(Int(currentAmount)) / \(Int(targetValue)) \(habit.targetValueUnit!.abbreviation)")
                if progress < 1.0 {
                    Button("", systemImage: "plus") {
                        isAddAmountPresented = true
                    }
                } else {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primary)
                }
            }
            if viewModel.isLoadingSteps {
                ProgressView().frame(height: 10)
            } else {
                
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
                
                .onAppear {
                    currentAmount = viewModel.state.habitRecords
                        .first(where: { $0.habitDefinition.id == habit.id })?.value ?? 0
                    if habit.isUsingHealthData && habit.targetValueUnit == .Steps {
                        currentAmount = Float(viewModel.stepsToday)
                    }
                }
                .sheet(isPresented: $isAddAmountPresented) {
                    VStack(spacing: 20) {
                        Text("Add Amount")
                            .font(.headline)
                        
                        TextField(
                            "Add Amount",
                            value: $amountToAdd,
                            format: .number
                        )
                        //Stepper(value: $amountToAdd, in: 0...habit.targetValue!, step: 0.1) {
                        //    Text("Amount: \(String(format: "%.1f", amountToAdd)) \(habit.targetValueUnit!.abbreviation)")
                        //}
                        
                        Button("Confirm") {
                            viewModel.addToAmountHabit(habit: habit, addedAmount: amountToAdd)
                            currentAmount += amountToAdd
                            amountToAdd = 0
                            isAddAmountPresented = false
                        }
                        
                        Button("Cancel", role: .cancel) {
                            isAddAmountPresented = false
                            amountToAdd = 0
                        }
                    }
                    .padding()
                    .presentationDetents([.fraction(0.25)])
                }
            }
        }
    }
}

#Preview {
    //DailyGoalProgressBar(currentAmount: <#T##Double#>, goal: <#T##Double#>)
}
