
import SwiftUI

struct DailyGoalProgressBar: View {
    @Binding var viewModel: DailyViewModel
    var habit: HabitDefinition
    @State private var currentAmount: Float = 0.0
    @State private var isAddAmountPresented = false
    @State private var amountToAdd: Float = 0.0
    @State private var amountText: String = "0"


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
                Text("\(currentAmount, specifier: "%.2f") / \(targetValue,  specifier: "%.2f") \(habit.targetValueUnit!.abbreviation)")
                if progress < 1.0 {
                    Button("", systemImage: "plus") {
                        isAddAmountPresented = true
                    }
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
                    currentAmount = viewModel.state.habitRecords
                        .first(where: { $0.habitDefinition.id == habit.id })?.value ?? 0
                    if habit.isUsingHealthData && habit.targetValueUnit == .Steps {
                        currentAmount = Float(viewModel.stepsToday)
                    }
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

//                            TextField("0", value: $amountToAdd, format: .number)
//                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 40, weight: .medium))
                                .frame(width: 120)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundStyle(Color.TextDarkPrimary, Color.TextLight)
//                                .onChange(of: amountToAdd) { newValue in
//                                    let filtered = newValue.filter { $0.isNumber }
//                                    amountToAdd = filtered
//                                }
//                            
//                            Text(habit.targetValueUnit?.abbreviation ?? "")
//                                .font(.system(size: 40, weight: .medium))
                        }
                        
                        Button("Confirm") {
                            viewModel.addToAmountHabit(habit: habit, addedAmount: amountToAdd)
                            currentAmount += amountToAdd
                            amountToAdd = 0
                            amountText = "0"
                            isAddAmountPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.Primary)
                        .controlSize(.large)
                        .disabled(!isValidFloat(amountText))
                        
                    }
                    .frame(alignment: .center)
                    .padding()
                    .presentationDetents([.fraction(0.3)])
                    .presentationBackground(Color.Background)
                }
            }
        }
    }

}

#Preview {
    //DailyGoalProgressBar(currentAmount: <#T##Double#>, goal: <#T##Double#>)
}
