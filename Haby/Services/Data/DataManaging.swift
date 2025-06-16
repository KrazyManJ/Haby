import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func fetch<T: NSManagedObject>() -> [T]
    
    func insert<T: NSManagedObject>(entity: T)
    func update<T: NSManagedObject>(entity: T)
    func delete<T: NSManagedObject>(entity: T)
}
