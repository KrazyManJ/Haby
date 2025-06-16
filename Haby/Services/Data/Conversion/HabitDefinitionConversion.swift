
extension HabitDefinition : EntityConverting {
    func toEntity() -> HabitDefinitionEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitDefinitionEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.name = name
        entity.type = type.rawValue
        entity.frequency = frequency.rawValue
        entity.targetValue = targetValue ?? 0.0
        entity.targetTimestamp = Int16(targetTimestamp ?? 0)
        entity.isActive = isActive
        entity.isUsingHealthData = isUsingHealthData
        entity.icon = icon
        entity.targetValueUnit = targetValueUnit
        
        return entity
    }
}

extension HabitDefinitionEntity : ModelConverting {
    func toModel() -> HabitDefinition {
        return HabitDefinition(
            id: id!,
            name: name!,
            icon: icon ?? "",
            type: HabitType(rawValue: type)!,
            frequency: HabitFrequency(rawValue: frequency)!,
            targetTimestamp: Int(targetTimestamp),
            targetValue: Float(targetValue),
            targetValueUnit: targetValueUnit!,
            isActive: isActive,
            isUsingHealthData: isUsingHealthData
        )
    }
}
