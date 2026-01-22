import SwiftUI

import SwiftUI

struct AmountHabitDetailView: View {
    let habit: HabitDefinition
    @ObservedObject var sessionManager = WatchSessionManager.shared
    
    @State private var isInputMode = false
    @State private var amountToAdd: Double = 0.0
    
    var record: HabitRecord? { sessionManager.records.first(where: { $0.habitDefinition.id == habit.id }) }
    var status: HabitStatusHelper { HabitStatusHelper(habit: habit, record: record) }
    
    var amountData: (current: Float, target: Float, unit: String) {
        // 1. Unwrap the Habit Definition data
        if case .Amount(let defData) = habit.data {
            
            // 2. Safely Unwrap the Record data
            // We check if record exists AND if its data matches .Amount
            var current: Float = 0
            if let r = record, case .Amount(let recordData) = r.data {
                current = recordData.value
            }
            
            return (current, defData.amount, defData.unit.abbreviation)
        }
        
        // Fallback (Should never happen for this view)
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
        .animation(.easeInOut, value: isInputMode)
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
                    through: 10000,
                    by: 10,
                    sensitivity: .high,
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
    }
    
    func saveProgress() {
        guard amountToAdd > 0 else {
            isInputMode = false
            return
        }
        
        WatchSessionManager.shared.addAmount(to: habit, amount: Float(amountToAdd))
        
        amountToAdd = 0
        isInputMode = false
    }
}
