
import CoreData

protocol EntityConverting<E> {
    associatedtype E: NSManagedObject
    func toEntity() -> E
}
