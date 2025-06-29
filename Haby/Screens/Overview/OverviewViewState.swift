
import Observation
import SwiftUI

@Observable
final class OverviewViewState {
    var selectedDateData: SelectedDateData?
    
    var stepsToday: Int = 0
    var monthlySteps: [StepData] = []
    var completedDates: Set<Date> = Set()
    var streak: Int = 0
    var moodRecords: [MoodRecord] = []
}
