import UIKit
import CoreData

extension HabitRecord : EntityConverting {
    func toEntity() -> HabitRecordEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitRecordEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.date = self.data.details.date
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self.data) {
            entity.data = jsonData
        }
        
        let habit: HabitDefinitionEntity? = dataManaging.wrappedValue.fetchOneById(id: habitDefinition.id)
        entity.habitDefinition = habit
        
        return entity
    }
}

extension HabitRecordEntity : ModelConverting {
    func toModel() -> HabitRecord {
        var data: HabitRecordData {
            let decoder = JSONDecoder()
            return try! decoder.decode(HabitRecordData.self, from: self.data!)
        }
        
        var timestamp: Int?
        var value: Float?
        
        switch data {
        case .Amount(let data):
            value = data.value
        case .Deadline(let data):
            timestamp = data.minutesOfCompletionInFrequency
        case .OnTime(let data):
            timestamp = data.minutesOfCompletionInFrequency
        }
        
        return HabitRecord(
            id: id!,
            date: data.details.date,
            timestamp: timestamp,
            value: value,
            habitDefinition: habitDefinition!.toModel(),
            data: data
        )
    }
}
