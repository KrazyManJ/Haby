import UIKit

extension HabitRecord : EntityConverting {
    func toEntity() -> HabitRecordEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitRecordEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.date = date
        entity.timestamp = Int16(timestamp ?? -1)
        entity.value = value ?? -1
        
        let habit: HabitDefinitionEntity? = dataManaging.wrappedValue.fetchOneById(id: habitDefinition.id)
        entity.habitDefinition = habit
        
        return entity
    }
}

extension HabitRecordEntity : ModelConverting {
    func toModel() -> HabitRecord {
        return HabitRecord(
            id: id ?? UUID(),
            date: date!,
            timestamp: Int(timestamp),
            value: value,
            habitDefinition: habitDefinition!.toModel()
        )
    }
}
