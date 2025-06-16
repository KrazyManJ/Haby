import CoreData

final class CoreDataManager: DataManaging {
    private let container = NSPersistentContainer(name: "Haby")
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Cannot create persistent store: \(error.localizedDescription)")
            }
        }
    }
    
    func insert<T: NSManagedObject>(entity: T) {
        save()
    }
    
    func update<T: NSManagedObject>(entity: T) {
        save()
    }
    
    func delete<T: NSManagedObject>(entity: T) {
        context.delete(entity)
        save()
    }
    
    func fetch<T: NSManagedObject>() -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        var lines: [T] = []
        
        do {
            lines = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        
        return lines
    }
}

private extension CoreDataManager {
    private func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Cannot save MOC: \(error.localizedDescription)")
            }
        }
    }

}
