import SwiftUI

struct WeeklyGoalProgressBar: View {
    @Binding var viewModel: WeeklyViewModel
    var habit: HabitDefinition
    
    var body: some View {
        AmountGoalProgressBar(
            habit: habit,
            currentValue: viewModel.totalWeeklyAmount(for: habit),
            isLoading: viewModel.isLoadingSteps && habit.isUsingHealthData == true,
            onAddAmount: { addedValue in
                viewModel.addToWeeklyAmountHabit(habit: habit, addedAmount: addedValue)
            }
        )
        .onAppear {
            // Keep your original side effect if needed
            viewModel.getWeekHabits()
        }
    }
}
