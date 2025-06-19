import CoreData

extension CoreDataManager {
    func getTimeHabitsForToday() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getTimeHabitsEntitiesForToday()
        return result
            .map { r in r.toModel()}
            .sorted {a,b in
                a.targetTimestamp! % WeekDay.MINUTES_IN_DAY
                <=
                b.targetTimestamp! % WeekDay.MINUTES_IN_DAY
            }
    }
    
    internal func getTimeHabitsEntitiesForToday() -> [HabitDefinitionEntity] {
        return fetch(
            predicate: NSPredicate(
                format:"type != %d AND ((frequency == %d) OR (frequency == %d AND targetTimestamp >= %d AND targetTimestamp <= %d))",
                argumentArray: [
                    HabitType.Amount.rawValue,
                    HabitFrequency.Daily.rawValue,
                    HabitFrequency.Weekly.rawValue,
                    WeekDay.getTodayWeekDay().toTimestamp,
                    WeekDay.getTomorrowWeekDay().toTimestamp
                ]
            )
        )
    }
}
