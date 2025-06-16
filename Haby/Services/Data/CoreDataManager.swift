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
    
    func fetch<T: NSManagedObject>() -> [T] {
        return fetch(predicate: nil)
    }
    
    func upsert<T: NSManagedObject>(entity: T) where T:Identifiable  {
        if let fromData: T = fetchOne(
            predicate: NSPredicate(format: "id = %@", entity.id as! NSUUID)
        ) {
            let description = NSEntityDescription.entity(
                forEntityName: .init(describing: T.self),
                in: context
            )
            
            let entityKeys: [String] = if let attributes = description?.attributesByName { Array(attributes.keys) } else { [] }
            
            for key in entityKeys {
                fromData.setValue(entity.value(forKey: key), forKey: key)
            }
            context.delete(entity)
        }
        save()
    }
    
    func delete<T: NSManagedObject>(entity: T) {
        context.delete(entity)
        save()
    }
    
    func getMoodRecordByDate(date: Date) -> MoodRecordEntity? {
        return fetchOne(
            predicate: NSPredicate(format: "date = %@",date as NSDate)
        )
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
    
    private func fetch<T: NSManagedObject>(
        predicate: NSPredicate? = nil
    ) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        if predicate != nil {
            request.predicate = predicate
        }
        var lines: [T] = []
        
        do {
            lines = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        
        return lines
    }
    
    private func fetchOne<T: NSManagedObject>(
        predicate: NSPredicate? = nil
    ) -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        if predicate != nil {
            request.predicate = predicate
        }
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        return nil
    }
}
