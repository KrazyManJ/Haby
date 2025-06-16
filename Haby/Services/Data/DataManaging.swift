import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func fetch<T: NSManagedObject>() -> [T]
    
    func insert(entity: HabitDefinitionEntity)
    func update(entity: HabitDefinitionEntity)
    func delete(entity: HabitDefinitionEntity)
}
