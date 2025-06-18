import CoreData

extension CoreDataManager {
    func getTodayRecords() -> [HabitRecord] {
        let habits = getHabitsEntitiesForToday()
        
        let result: [HabitRecordEntity] = fetch(
            predicate: NSPredicate(format:"habitDefinition IN %@",habits)
        );
        return result.map { $0.toModel() }
    }
}
