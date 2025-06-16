import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func fetch<T: NSManagedObject>() -> [T]

    func upsert<T: NSManagedObject>(entity: T) where T:Identifiable
    func delete<T: NSManagedObject>(entity: T)
    
    func getMoodRecordByDate(date: Date) -> MoodRecordEntity?
}
