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
        
        var data: HabitDefinitionData {
            switch type {
            case .Amount:
                return .Amount(data: .init(
                    frequency: frequency,
                    amount: Float(targetValue),
                    unit: AmountUnit(rawValue: targetValueUnit)!
                ))
            case .Deadline:
                return .Deadline(data: .init(
                    frequency: frequency,
                    minutesOfCompletionInFrequency: Int(targetTimestamp))
                )
            case .OnTime:
                return .OnTime(data: .init(
                    frequency: frequency,
                    minutesOfCompletionInFrequency: Int(targetTimestamp)
                ))
            }
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
