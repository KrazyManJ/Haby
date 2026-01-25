import CoreData

extension HabitDefinition : EntityConverting {
    func toEntity() -> HabitDefinitionEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitDefinitionEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.name = name
        entity.isUsingHealthData = isUsingHealthData
        entity.icon = icon
        entity.creationDate = creationDate.onlyDate
        entity.type = self.data.type.rawValue
        entity.frequency = self.data.details.frequency.rawValue
        
        switch self.data {
        case .Amount(let data):
            entity.targetValue = data.amount
            entity.targetValueUnit = data.unit.rawValue
        case .Deadline(let data):
            entity.targetTimestamp = data.minutesOfCompletionInFrequency.int16
        case .OnTime(let data):
            entity.targetTimestamp = data.minutesOfCompletionInFrequency.int16
        }
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self.data) {
            entity.data = jsonData
        }
        
        return entity
    }
}

extension HabitDefinitionEntity : ModelConverting {
    func toModel() -> HabitDefinition {
        var data: HabitDefinitionData {
            let decoder = JSONDecoder()
            return try! decoder.decode(HabitDefinitionData.self, from: self.data!)
        }
        
        var targetTimestamp: Int?
        var targetValue: Float?
        var targetValueUnit: AmountUnit?
        
        switch data {
        case .Amount(let data):
            targetValue = data.amount
            targetValueUnit = data.unit
        case .Deadline(let data):
            targetTimestamp = data.minutesOfCompletionInFrequency
        case .OnTime(let data):
            targetTimestamp = data.minutesOfCompletionInFrequency
        }
        
        
        
        return HabitDefinition(
            id: id!,
            name: name!,
            icon: icon ?? "",
            creationDate: creationDate!,
            type: data.type,
            frequency: data.details.frequency,
            targetTimestamp: targetTimestamp,
            targetValue: targetValue,
            targetValueUnit: targetValueUnit,
            isUsingHealthData: isUsingHealthData,
            data: data
        )
    }
}
