
import SwiftUI

@Observable
final class MainTabViewState {
    var streak: Int = 0
    var habitToShowOnNavigation: HabitDefinition?
}
