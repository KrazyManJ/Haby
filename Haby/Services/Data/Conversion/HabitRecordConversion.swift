import UIKit
import CoreData

extension HabitRecord : EntityConverting {
    func toEntity() -> HabitRecordEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitRecordEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.date = data.details.date
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self.data) {
            entity.data = jsonData
        }
        
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
        
        var data: HabitRecordData! {
            guard let blob = self.data else {
                return nil
            }
            
            let decoder = JSONDecoder()
            return try! decoder.decode(HabitRecordData.self, from: blob)
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
