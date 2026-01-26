import SwiftUI
import HealthKit

@Observable
class DetailViewModel {
    var state: DetailViewState
    
    @ObservationIgnored @Injected private var dataManaging: DataManaging
    @ObservationIgnored @Injected private var healthKitManager: HealthManaging
    @ObservationIgnored @Injected private var phoneSessionManager: PhoneSessionManaging

    
    init(habit: HabitDefinition) {
        state = DetailViewState(habit: habit)
    }
    
    func getHabitRecord(){
        let records = dataManaging.getTodayRecords()
        state.record = records.first { $0.habitDefinition.id == state.habit.id }
    }
    
    func checkHabit(habit: HabitDefinition) {
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let currentTimestamp = hour * 60 + minute
        
        if let record = state.record {
            if let entity: HabitRecordEntity = dataManaging.fetchOneById(id: record.id) {
                dataManaging.delete(entity: entity)
            }
            self.state.record = nil
        }
        else {
            var recordData: HabitRecordData {
                if habit.data.type == .Deadline {
                    return .Deadline(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: currentTimestamp))
                } else {
                    return .OnTime(data: .init(date: Date().onlyDate, minutesOfCompletionInFrequency: currentTimestamp))
                }
            }
            
            let newRecord = HabitRecord(
                date: Date().onlyDate,
                timestamp: currentTimestamp,
                habitDefinition: habit,
                data: recordData
            )
            
            dataManaging.upsert(model: newRecord)
            
            self.state.record = newRecord
        }
        phoneSessionManager.syncAllHabitsToWatch()
    }
    
    func addToAmountHabit(habit: HabitDefinition, addedAmount: Float) {
        let today = Date().onlyDate

        if var record = state.record {
            switch record.data {
            case .Amount(var data):
                data.value += addedAmount
                record.data = .Amount(data: data)
                record.value = (record.value ?? 0) + addedAmount
                dataManaging.upsert(model: record)
                self.state.record = record
            default:
                break
            }
        } else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: today,
                value: addedAmount,
                habitDefinition: habit,
                data: .Amount(data: .init(date: today, value: addedAmount))
            )
            dataManaging.upsert(model: newRecord)
            self.state.record = newRecord
            
            phoneSessionManager.syncAllHabitsToWatch()
        }
    }
}
