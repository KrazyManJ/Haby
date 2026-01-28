import SwiftUI

import SwiftUI

struct AmountHabitDetailView: View {
    @Binding var viewModel: HabitListViewModel
    
    let habit: HabitDefinition
    
    var goal: Double {
        switch habit.data {
        case .Amount(let data): Double(data.amount)
        default: 1
        }
    }
    
    var step: Double {
        switch habit.data {
        case .Amount(let data): Double(data.amount/20)
        default: 1
        }
    }
    
    @State private var isInputMode = false
    @State private var amountToAdd: Double = 0.0
    
    var record: HabitRecord? { viewModel.state.records.first(where: { $0.habitDefinition.id == habit.id }) }
    var status: HabitStatusHelper { HabitStatusHelper(habit: habit, record: record) }
    
    var amountData: (current: Float, target: Float, unit: String) {
        if case .Amount(let defData) = habit.data {
            var current: Float = 0
            if let r = record, case .Amount(let recordData) = r.data {
                current = recordData.value
            }
            
            return (current, defData.amount, defData.unit.abbreviation)
        }
        
        return (0, 1, "")
    }
    
    var body: some View {
        VStack {
            if isInputMode {
                inputModeView
            } else {
                overviewModeView
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: isInputMode)
        .background(.backgroundPrimary)
    }
    
    var overviewModeView: some View {
            VStack(spacing: 16) {
                HabitDetailHeader(habit: habit, status: status, isChecked: false)
                HabitProgressBar(
                    current: amountData.current,
                    target: amountData.target,
                    color: .brandPrimary
                )
                Button {
                    isInputMode = true
                } label: {
                    Text("Add Progress")
                        .fontWeight(.semibold)
                }
                .tint(Colors.Primary)
            }
    }
    
    var inputModeView: some View {
        VStack(spacing: 12) {
            
            Text(String(format: "%.0f", amountToAdd, amountData.unit))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(Colors.Primary)
                .focusable(true)
                .digitalCrownRotation(
                    $amountToAdd,
                    from: 0,
                    through: goal,
                    by: step,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
            
            Spacer()
            Button {
                saveProgress()
            } label: {
                Text("Save")
            }
            .tint(Colors.Primary)
            
        }
        .frame(maxWidth: .infinity)
    }
    
    func saveProgress() {
        guard amountToAdd > 0 else {
            isInputMode = false
            return
        }
        
        viewModel.addToAmountHabit(habit: habit, addedAmount: Float(amountToAdd))
        
        amountToAdd = 0
        isInputMode = false
    }
}
