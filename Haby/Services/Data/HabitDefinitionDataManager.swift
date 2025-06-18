import CoreData

extension CoreDataManager {
    func getHabitsForToday() -> [HabitDefinition] {
        let result: [HabitDefinitionEntity] = getHabitsEntitiesForToday()
        return result.map { r in r.toModel()}
    }
    
    internal func getHabitsEntitiesForToday() -> [HabitDefinitionEntity] {
        return fetch(
            predicate: NSPredicate(
                format:"(frequency == %d) OR (frequency == %d AND targetTimestamp >= %d AND targetTimestamp <= %d)",
                argumentArray: [
                    HabitFrequency.Daily.rawValue,
                    HabitFrequency.Weekly.rawValue,
                    WeekDay.getTodayWeekDay().rawValue,
                    WeekDay.getTomorrowWeekDay().rawValue
                ]
            )
        )
    }
}
