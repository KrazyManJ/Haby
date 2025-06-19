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
    
    func getAmountHabitsForToday() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getAmountHabitsEntitiesForDate(date: Date())
        return result
            .map { $0.toModel() }
    }
    
    func getHabitsForDate(date: Date) -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getTimeHabitsEntitiesForDate(date: Date())
        return result.map { $0.toModel() }
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
                    today.nextDay().toTimestamp,
//                    WeekDay.getTodayWeekDay().toTimestamp,
//                    WeekDay.getTomorrowWeekDay().toTimestamp
                ]
            )
        )
    }
    
    internal func getAmountHabitsEntitiesForDate(date: Date) -> [HabitDefinitionEntity] {
        let today = WeekDay(from: date)
        return fetch(
            predicate: NSPredicate(
                format: "type == %d AND ((frequency == %d) OR (frequency == %d AND targetTimestamp >= %d AND targetTimestamp <= %d))",
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

}
