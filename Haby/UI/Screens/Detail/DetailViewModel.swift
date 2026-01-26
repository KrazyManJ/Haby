import SwiftUI
import HealthKit

@Observable
class DetailViewModel {
    var state: DetailViewState
    
    @ObservationIgnored @Injected private var dataManaging: DataManaging
    @ObservationIgnored @Injected private var healthKitManager: HealthManaging

//    init(habit: HabitDefinition, record: HabitRecord) {
//        state = DetailViewState(habit: habit, record: record)
//    }
    
    init(habit: HabitDefinition) {
        state = DetailViewState(habit: habit)
    }
    
    func getHabitRecord(){
        let records = dataManaging.getTodayRecords()
        state.record = records.first { $0.habitDefinition.id == state.habit.id }
    }
    
//    func getRecordState(from habit: HabitDefinition) -> Int {
//        switch state.record?.data {
//        case .OnTime(let data): return data.minutesOfCompletionInFrequency
//        case .Deadline(let data): return data.minutesOfCompletionInFrequency
//        default: return Int.max
//        }
//    }
}
