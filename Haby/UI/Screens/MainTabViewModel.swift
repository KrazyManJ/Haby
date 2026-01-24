
import SwiftUI

@Observable
class MainTabViewModel: ObservableObject {
    
    var state = MainTabViewState()
    
    @ObservationIgnored @Injected private var habitManager: HabitManaging
    
    func fetchStreak() {
        state.streak = habitManager.calculateCurrentStreak()
    }
}
