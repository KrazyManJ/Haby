
extension HabitDefinition : EntityConverting {
    func toEntity() -> HabitDefinitionEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = HabitDefinitionEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.name = name
        entity.type = type.rawValue
        entity.frequency = frequency.rawValue
        entity.targetValue = targetValue ?? -1
        entity.targetTimestamp = Int16(targetTimestamp ?? -1)
        entity.isActive = isActive
        entity.isUsingHealthData = isUsingHealthData
        entity.icon = icon
        entity.targetValueUnit = (targetValueUnit ?? .None).rawValue
        entity.creationDate = creationDate
        
        return entity
    }
}

extension HabitDefinitionEntity : ModelConverting {
    func toModel() -> HabitDefinition {
        return HabitDefinition(
            id: id!,
            name: name!,
            icon: icon ?? "",
            creationDate: creationDate!,
            type: HabitType(rawValue: type)!,
            frequency: HabitFrequency(rawValue: frequency)!,
            targetTimestamp: targetTimestamp == -1 ? nil : Int(targetTimestamp),
            targetValue: targetValue == -1 ? nil : Float(targetValue),
            targetValueUnit: AmountUnit(rawValue: targetValueUnit)!,
            isActive: isActive,
            isUsingHealthData: isUsingHealthData
        )
    }
}
