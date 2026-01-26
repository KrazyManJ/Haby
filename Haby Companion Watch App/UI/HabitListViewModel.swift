
import Foundation

@Observable
class HabitListViewModel {
    
    var state: HabitListViewState
    
    @ObservationIgnored @Injected private var dataManager: DataManaging
    @ObservationIgnored @Injected private var watchSessionManager: WatchSessionManaging
    
    init(filterType: InternalHabitCategory) {
        state = .init(filterType: filterType)
        _ = watchSessionManager
    }
    
    func fetchHabits() {
        switch state.filterType {
        case .Numeric:
            state.habits = dataManager.getAmountHabitsForToday()
        case .Timer:
            state.habits = dataManager.getTimeHabitsForToday()
        }
        state.records = dataManager.getTodayRecords()
    }
    
    func checkHabit(habit: HabitDefinition) {
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let currentTimestamp = hour * 60 + minute
        
        
        
        if let record = state.records.first(where: { $0.habitDefinition.id == habit.id }) {
            if let entity: HabitRecordEntity = dataManager.fetchOneById(id: record.id) {
                dataManager.delete(entity: entity)
                watchSessionManager.sendRecordRemoval(recordId: record.id)
            }
        }
        else {
            var recordData: HabitRecordData {
                if habit.data.type == .Deadline {
                    return .Deadline(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: currentTimestamp))
                } else {
                    return .OnTime(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: currentTimestamp))
                }
            }
            let record = HabitRecord(
                date: Date().onlyDate,
                timestamp: currentTimestamp,
                habitDefinition: habit,
                data: recordData
            )
            dataManager.upsert(model: record)
            watchSessionManager.sendRecordData(record: record)
        }
        fetchHabits()
    }
    
    func addToAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let today = Date().onlyDate

        if var record = state.records.first(where: { $0.habitDefinition.id == habit.id }) {
            switch record.data {
            case .Amount(var data):
                data.value += addedAmount
                record.data = .Amount(data: data)
                record.value = (record.value ?? 0) + addedAmount
                dataManager.upsert(model: record)
            default:
                break
            }
            watchSessionManager.sendRecordData(record: record)
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit,
                data: .Amount(data: .init(date: today, value: addedAmount))
            )
            dataManager.upsert(model: newRecord)
            watchSessionManager.sendRecordData(record: newRecord)
        }
        fetchHabits()
    }
}
