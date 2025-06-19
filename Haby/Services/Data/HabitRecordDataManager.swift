import CoreData

extension CoreDataManager {
    func getTodayRecords() -> [HabitRecord] {
        return getRecordsByDate(date: Date())
    }
    
    func getRecordsByDate(date: Date) -> [HabitRecord] {
        let habits = getTimeHabitsEntitiesForDate(date: date)
        
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
    
    func fetchAllRecordsSortedByDate() -> [HabitRecord] {
        let result: [HabitRecordEntity] = fetch(
            sortDescriptions: [
                NSSortDescriptor(key: "date", ascending: true)
            ]
        )
        return result.map { $0.toModel() }
    }
    
    func fetchDatesWithHabitRecords() -> [Date] {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: String(describing: HabitRecordEntity.self))
        fetchRequest.propertiesToFetch = ["date"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0["date"] as? Date }
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        return []
    }
}
