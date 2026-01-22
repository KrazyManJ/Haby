import UIKit
import CoreData

extension HabitRecord : EntityConverting {
    func toEntity() -> HabitRecordEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitRecordEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.date = date
        
        switch self.data {
        case .Amount(let data):
            entity.value = data.value
        case .Deadline(let data):
            entity.timestamp = data.minutesOfCompletionInFrequency.int16
        case .OnTime(let data):
            entity.timestamp = data.minutesOfCompletionInFrequency.int16
        }
        
        let habit: HabitDefinitionEntity? = dataManaging.wrappedValue.fetchOneById(id: habitDefinition.id)
        entity.habitDefinition = habit
        
        return entity
    }
}

extension HabitRecordEntity : ModelConverting {
    func toModel() -> HabitRecord {
        
        let type: HabitType = HabitType(rawValue: self.habitDefinition!.type)!
        
        var data: HabitRecordData {
            switch type {
            case .Amount:
                return .Amount(data: .init(value: self.value))
            case .Deadline:
                return .Deadline(data: .init(minutesOfCompletionInFrequency: self.timestamp.int))
            case .OnTime:
                return .OnTime(data: .init(minutesOfCompletionInFrequency: self.timestamp.int))
            }
        }
        
        return HabitRecord(
            id: id!,
            date: date!,
            timestamp: Int(timestamp),
            value: value,
            habitDefinition: habitDefinition!.toModel(),
            data: data
        )
    }
}
