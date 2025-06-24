
import SwiftUI

struct WeeklyGoalProgressBar: View {
    @Binding var viewModel: WeeklyViewModel
    var habit: HabitDefinition
    @State private var isAddAmountPresented = false
    @State private var amountToAdd: Float = 0.0
    @State private var amountText: String = "0"

    var currentAmount: Float {
        viewModel.totalWeeklyAmount(for: habit)
    }

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
                Text("\(currentAmount.trimmedString) / \(targetValue.trimmedString) \(habit.targetValueUnit!.abbreviation)")
                    .font(.caption)
                if progress < 1.0 {
                    Button("", systemImage: "plus") {
                        isAddAmountPresented = true
                    }
                    .foregroundColor(.primary)
                } else {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primary)
                }
            }

            if viewModel.isLoadingSteps && habit.isUsingHealthData == true {
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
                    viewModel.getWeekHabits()
                }
                .sheet(isPresented: $isAddAmountPresented) {
                    VStack(spacing: 20) {
                        HStack{
                            Text("Add Amount")
                                .font(.headline)
                                .frame(alignment: .leading)
                            Spacer()
                            Button(action: {
                                isAddAmountPresented = false
                                amountToAdd = 0
                            }) {
                                Image(systemName: "xmark")
                                    .frame(width: 30, height: 30)
                                    .font(.system(size: 20))
                                    .tint(Color.TextDarkPrimary)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            FloatTextField(value: $amountToAdd, rawText: $amountText)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 40, weight: .medium))
                                .frame(width: 150)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundStyle(Color.TextDarkPrimary, Color.TextLight)
                        }
                        
                        Button("Confirm") {
                            viewModel.addToWeeklyAmountHabit(habit: habit, addedAmount: amountToAdd)
                            //currentAmount += amountToAdd
                            amountToAdd = 0
                            amountText = "0"
                            isAddAmountPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.Primary)
                        .controlSize(.large)
                        .disabled(!isAddAmountInputValid())
                        
                    }
                    .frame(alignment: .center)
                    .padding()
                    .presentationDetents([.fraction(0.3)])
                    .presentationBackground(Color.Background)
                }
            }
        }
    }
    
    func isAddAmountInputValid() -> Bool {
        guard habit.type == .Amount else { return true }
        guard let value = Float(amountText), value > 0 else { return false }
        if habit.targetValueUnit == .Steps && amountText.contains(".") {
                return false
            }
        return true
    }
}

#Preview {
    //DailyGoalProgressBar(currentAmount: <#T##Double#>, goal: <#T##Double#>)
}
