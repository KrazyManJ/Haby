import CoreData

extension HabitDefinition : EntityConverting {
    func toEntity() -> HabitDefinitionEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitDefinitionEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.name = name
        entity.type = data.type.rawValue
        entity.frequency = data.details.frequency.rawValue
        entity.isUsingHealthData = isUsingHealthData
        entity.icon = icon
        entity.creationDate = creationDate
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self.data) {
            entity.data = jsonData
        }
        
        switch self.data {
        case .Amount(let data):
            entity.targetValue = data.amount
            entity.targetValueUnit = data.unit.rawValue
        case .Deadline(let data):
            entity.targetTimestamp = data.minutesOfCompletionInFrequency.int16
        case .OnTime(let data):
            entity.targetTimestamp = data.minutesOfCompletionInFrequency.int16
        }
        
        return entity
    }
}

extension HabitDefinitionEntity : ModelConverting {
    func toModel() -> HabitDefinition {
        
        let type: HabitType = HabitType(rawValue: self.type)!
        let frequency = HabitFrequency(rawValue: self.frequency)!
        
        var data: HabitDefinitionData! {
            guard let blob = self.data else {
                return nil
            }
            
            let decoder = JSONDecoder()
            return try! decoder.decode(HabitDefinitionData.self, from: blob)
        }
        
        return HabitDefinition(
            id: id!,
            name: name!,
            icon: icon ?? "",
            creationDate: creationDate!,
            type: type,
            frequency: frequency,
            targetTimestamp: targetTimestamp == -1 ? nil : Int(targetTimestamp),
            targetValue: targetValue == -1 ? nil : Float(targetValue),
            targetValueUnit: AmountUnit(rawValue: targetValueUnit) ?? .None,
            isUsingHealthData: isUsingHealthData,
            data: data
        )
    }
}
