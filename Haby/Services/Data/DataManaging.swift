import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    var isEmpty: Bool { get }
    
    func insertMockupData()
    
    func fetch<E: NSManagedObject>() -> [E]
    func fetch<M:EntityConverting<E>, E: NSManagedObject>() -> [M] where E:ModelConverting<M>
    func fetchOneById<E: NSManagedObject>(id: UUID) -> E?
    func fetchOneById<M:EntityConverting<E>, E: NSManagedObject>(id: UUID) -> M? where E:ModelConverting<M>
    
    func upsert<E: NSManagedObject ,M: EntityConverting<E>>(model: M) where M:Identifiable<UUID>
    func delete<E: NSManagedObject>(entity: E)
    
    // HabitDefinitionDataManager
    func getTimeHabitsForToday() -> [HabitDefinition]
    func getAmountHabitsForToday() -> [HabitDefinition]
    func getTimeHabitsForDate(date: Date) -> [HabitDefinition]
    func getAmountHabitsForDate(date: Date) -> [HabitDefinition]
    func getHabitsForDate(date: Date) -> [HabitDefinition]
    
    func getTimeHabitsForWeek() -> [HabitDefinition]
    func getAmountHabitsForWeek() -> [HabitDefinition]
    
    // MoodDataManager
    func getMoodRecordByDate(date: Date) -> MoodRecordEntity?
    
    // HabitRecordDataManager
    func getRecordsByDate(date: Date) -> [HabitRecord]
    func getTodayRecords() -> [HabitRecord]
    func getWeekRecords() -> [HabitRecord]
    func fetchAllRecordsSortedByDate() -> [HabitRecord]
    func fetchDatesWithHabitRecords() -> [Date]
    
}
