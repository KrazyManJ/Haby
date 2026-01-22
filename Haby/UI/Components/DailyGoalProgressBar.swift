import SwiftUI

struct DailyGoalProgressBar: View {
    @Binding var viewModel: DailyViewModel
    var habit: HabitDefinition
    
    var currentValue: Float {
        if habit.isUsingHealthData, let unit = habit.targetValueUnit {
            let value = viewModel.healthData[unit] ?? 0.0
            return Float(value)
        } else {
            return viewModel.state.habitRecords
                .first(where: { $0.habitDefinition.id == habit.id })?.value ?? 0
        }
    }
    
    var body: some View {
        AmountGoalProgressBar(
            habit: habit,
            currentValue: currentValue,
            isLoading: habit.isUsingHealthData && viewModel.healthData[habit.targetValueUnit!] == nil,
            onAddAmount: { addedValue in
                viewModel.addToAmountHabit(habit: habit, addedAmount: addedValue)
            }
        )
    }
}
