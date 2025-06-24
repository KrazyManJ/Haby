import CoreData

extension CoreDataManager {
    func getTodayRecords() -> [HabitRecord] {
        return getRecordsByDate(date: Date())
    }
    
    func getWeekRecords() -> [HabitRecord] {
        return getRecordsForWeek(of: Date())
    }

    func getRecordsByDate(date: Date) -> [HabitRecord] {
        let timeHabits = getTimeHabitsEntitiesForDate(date: date)
        let amountHabits = getAmountHabitsEntitiesForDate(date: date)
        let allHabits = timeHabits + amountHabits

        let result: [HabitRecordEntity] = fetch(
            predicate: NSPredicate(
                format:"habitDefinition IN %@ AND date = %@",
                argumentArray: [
                    allHabits,
                    date.onlyDate as NSDate
                ]
            )
        );
        return result.map { $0.toModel() }
    }
    
    func getRecordsForWeek(of date: Date) -> [HabitRecord] {
        let startOfWeek = date.startOfWeek
        let endOfWeek = date.endOfWeek
        
        let weeklyHabits: [HabitDefinitionEntity] = fetch(
            predicate: NSPredicate(
                format: "frequency = %d",
                argumentArray: [
                    HabitFrequency.Weekly.rawValue
                ]
            )
        )

        let predicate = NSPredicate(
            format: "habitDefinition IN %@ AND date >= %@ AND date <= %@",
            argumentArray: [
                weeklyHabits,
                startOfWeek.onlyDate as NSDate,
                endOfWeek.onlyDate as NSDate
            ]
        )
        
        
        
        let result: [HabitRecordEntity] = fetch(predicate: predicate)
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
