import SwiftUI

struct GoalHabitRow: View {
    
    var habit: HabitDefinition
    var currentAmount: Float
    var onAdd: (Float) -> Void
    
    @State private var isAddingSheetPresented = false
    
    
    private var goalAmount: Float {
        switch habit.data {
        case .Amount(let data):
            return data.amount
        default:
            return -1
        }
    }
    
    private var goalUnit: String {
        switch habit.data {
        case .Amount(let data):
            return data.unit.abbreviation
        default:
            return ""
        }
    }
    
    private var percentageOfCompletion: CGFloat { CGFloat(min(currentAmount / goalAmount, 1.0)) }
    
    private var progressBarOpacity: CGFloat { percentageOfCompletion * 0.7 + 0.3 }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: habit.icon)
                    .font(.title2)
                Text(habit.name)
                    .font(.callout)
                    .bold()
                Spacer()
                Text("\(currentAmount.cleanString) / \(goalAmount.cleanString) \(goalUnit)")
                    .font(.caption2)
                    .foregroundStyle(.textSecondary)
                if (!habit.isUsingHealthData){
                    Button(action: {
                        isAddingSheetPresented = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .padding([.horizontal], 8)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.textOnPrimary)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.accent.opacity(progressBarOpacity))
                        .frame(width: geometry.size.width * percentageOfCompletion, height: 6)
                }
            }
        }
        .foregroundStyle(.textPrimary)
        .sheet(isPresented: $isAddingSheetPresented) {
            AddToGoalHabitSheet(fraction: goalAmount/20, onAdd: onAdd)
        }
    }
}

#Preview {
    GoalHabitRow(
        habit: HabitDefinition(
            name: "Walking",
            icon: "figure.walk",
            creationDate: Date(),
            type: .Amount,
            frequency: .Daily,
            data: .Amount(data: .init(frequency: .Daily, amount: 1000, unit: .Steps))
        ),
        currentAmount: 200
    ){_ in }.preferredColorScheme(.dark)
}
