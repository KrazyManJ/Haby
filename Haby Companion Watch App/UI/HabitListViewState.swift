
import Foundation

@Observable
final class HabitListViewState {
    var filterType: InternalHabitCategory
    
    var habits: [HabitDefinition] = []
    var records: [HabitRecord] = []
    
    init(filterType: InternalHabitCategory) {
        self.filterType = filterType
    }
}
