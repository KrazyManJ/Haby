
import SwiftUI

struct AddToGoalHabitSheet: View {
    
    let fraction: Float
    let onAdd: (Float) -> Void
    
    @State private var pickedAmount: Float = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(String(pickedAmount))
            HStack {
                Button(action: { pickedAmount = max(0, pickedAmount - fraction) }) {
                    Label("Decrease", systemImage: "minus")
                }
                .buttonStyle(.borderedProminent)
                .disabled(pickedAmount <= 0)
                .foregroundStyle(.textOnPrimary)
                
                Button(action: { pickedAmount += fraction }) {
                    Label("Increase", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.textOnPrimary)
            }
            Button(action: {
                onAdd(pickedAmount)
                dismiss()
            }) {
                Label("Add", systemImage: "checkmark")
            }
        }
        .padding()
        .presentationDetents([.fraction(0.3)])
        .presentationBackground(.backgroundPrimary)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    AddToGoalHabitSheet(fraction: 10) { addValue in
        
    }
}
