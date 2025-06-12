import Observation

@Observable
final class DailyViewState {
    var habits: [HabitDefinition] = []
}
