import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func fetch<E: NSManagedObject>() -> [E]
    func fetch<M:EntityConverting<E>, E: NSManagedObject>() -> [M] where E:ModelConverting<M>
    func fetchOneById<E: NSManagedObject>(id: UUID) -> E?
    func fetchOneById<M:EntityConverting<E>, E: NSManagedObject>(id: UUID) -> M? where E:ModelConverting<M>
    
    func upsert<E: NSManagedObject ,M: EntityConverting<E>>(model: M) where M:Identifiable<UUID>
    func delete<T: NSManagedObject>(entity: T)
    
    func getMoodRecordByDate(date: Date) -> MoodRecordEntity?
}
