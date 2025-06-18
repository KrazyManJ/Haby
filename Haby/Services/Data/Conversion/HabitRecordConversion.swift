import UIKit

extension HabitRecord : EntityConverting {
    func toEntity() -> HabitRecordEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitRecordEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.habitId = id
        entity.timestamp = Int16(timestamp ?? -1)
        entity.value = value ?? -1
        
        return entity
    }
}

extension HabitRecordEntity : ModelConverting {
    func toModel() -> HabitRecord {
        return HabitRecord(
            id: id ?? UUID(),
            habitId: habitId ?? UUID(),
            timestamp: Int(timestamp),
            value: value
        )
    }
}
