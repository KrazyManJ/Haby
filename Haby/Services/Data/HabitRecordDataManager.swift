import CoreData

extension CoreDataManager {
    func getTodayRecords() -> [HabitRecord] {
        let habits = getHabitsEntitiesForToday()
        
        let result: [HabitRecordEntity] = fetch(
            predicate: NSPredicate(
                format:"habitDefinition IN %@ AND date = %@",
                argumentArray: [
                    habits,
                    Date().onlyDate as NSDate
                ]
            )
        );
        return result.map { $0.toModel() }
    }
}
