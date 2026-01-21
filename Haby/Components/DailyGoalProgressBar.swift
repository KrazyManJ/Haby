import SwiftUI

struct DailyGoalProgressBar: View {
    @Binding var viewModel: DailyViewModel
    var habit: HabitDefinition
    
    var currentValue: Float {
        if habit.isUsingHealthData && habit.targetValueUnit == .Steps {
            return Float(viewModel.stepsToday)
        } else {
            return viewModel.state.habitRecords
                .first(where: { $0.habitDefinition.id == habit.id })?.value ?? 0
        }
    }
    
    var body: some View {
        AmountGoalProgressBar(
            habit: habit,
            currentValue: currentValue,
            isLoading: viewModel.isLoadingSteps && habit.isUsingHealthData == true,
            onAddAmount: { addedValue in
                // The Dumb View told us to add value, so we tell the ViewModel
                viewModel.addToAmountHabit(habit: habit, addedAmount: addedValue)
            }
        )
    }
}
