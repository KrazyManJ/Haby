import CoreData

extension CoreDataManager {
    func getTimeHabitsForToday() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getTimeHabitsEntitiesForDate(date: Date())
        return result
            .map { r in r.toModel()}
            .sorted {a,b in
                a.targetTimestamp! % WeekDay.MINUTES_IN_DAY
                <=
                b.targetTimestamp! % WeekDay.MINUTES_IN_DAY
            }
    }
    
    func getTimeHabitsForWeek() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getTimeHabitsEntitiesForWeek()
        return result
            .map { r in r.toModel()}
            .sorted {a,b in
                a.targetTimestamp! % WeekDay.MINUTES_IN_DAY
                <=
                b.targetTimestamp! % WeekDay.MINUTES_IN_DAY
            }
    }
    
    func getAmountHabitsForToday() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getAmountHabitsEntitiesForDate(date: Date())
        return result
            .map { $0.toModel() }
    }
    
    func getAmountHabitsForWeek() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getAmountHabitsEntitiesForWeek()
        return result
            .map { $0.toModel() }
    }
    
    func getTimeHabitsForDate(date: Date) -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getTimeHabitsEntitiesForDate(date: Date())
        return result.map { $0.toModel() }
    }
    
    func getAmountHabitsForDate(date: Date) -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getAmountHabitsEntitiesForDate(date: date)
        return result.map { $0.toModel() }
    }
    
    func getHabitsForDate(date: Date) -> [HabitDefinition] {
        return getTimeHabitsForDate(date: date)+getAmountHabitsForDate(date: date)
    }
    
    internal func getTimeHabitsEntitiesForDate(date: Date) -> [HabitDefinitionEntity] {
        let today: WeekDay = WeekDay(from: date)
        return fetch(
            predicate: NSPredicate(
                format:"type != %d AND ((frequency == %d) OR (frequency == %d AND targetTimestamp >= %d AND targetTimestamp <= %d))",
                argumentArray: [
                    HabitType.Amount.rawValue,
                    HabitFrequency.Daily.rawValue,
                    HabitFrequency.Weekly.rawValue,
                    today.toTimestamp,
                    today.nextDay().toTimestamp
                ]
            )
        )
    }
    
    internal func getTimeHabitsEntitiesForWeek() -> [HabitDefinitionEntity] {
        return fetch(
            predicate: NSPredicate(
                format:"type != %d AND frequency == %d",
                argumentArray: [
                    HabitType.Amount.rawValue,
                    HabitFrequency.Weekly.rawValue,
                ]
            )
        )
    }
    
    internal func getAmountHabitsEntitiesForDate(date: Date) -> [HabitDefinitionEntity] {
//        let today = WeekDay(from: date)
        return fetch(
            predicate: NSPredicate(
//                format: "type == %d AND ((frequency == %d) OR (frequency == %d AND targetTimestamp >= %d AND targetTimestamp <= %d))",
                format: "type == %d AND frequency == %d",
                argumentArray: [
                    HabitType.Amount.rawValue,
                    HabitFrequency.Daily.rawValue,
//                    HabitFrequency.Weekly.rawValue, // delete
//                    today.toTimestamp,
//                    today.nextDay().toTimestamp
                ]
            )
        )
    }
    
    internal func getAmountHabitsEntitiesForWeek() -> [HabitDefinitionEntity] {
        return fetch(
            predicate: NSPredicate(
                format: "type == %d AND frequency == %d",
                argumentArray: [
                    HabitType.Amount.rawValue,
                    HabitFrequency.Weekly.rawValue,
                ]
            )
        )
    }
}
