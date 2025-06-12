
extension HabitDefinition : EntityConverting {
    func toEntity() -> HabitDefinitionEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitDefinitionEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.name = name
        entity.type = type.rawValue
        entity.frequency = frequency.rawValue
        entity.targetValue = targetValue!
        entity.targetTimestamp = Int16(targetTimestamp!)
        entity.isActive = isActive
        entity.isUsingHealthData = isUsingHealthData
        
        return entity
    }
}

extension HabitDefinitionEntity : ModelConverting {
    func toModel() -> HabitDefinition {
        return HabitDefinition(
            id: id!,
            name: name!,
            type: HabitType(rawValue: type)!,
            frequency: HabitFrequency(rawValue: frequency)!,
            targetTimestamp: Int(targetTimestamp),
            targetValue: Float(targetValue),
            isActive: isActive,
            isUsingHealthData: isUsingHealthData
        )
    }
}
