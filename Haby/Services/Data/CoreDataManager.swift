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
    
    func fetch<M, E>() -> [M] where M : EntityConverting, M == E.M, E : ModelConverting, E == M.E {
        let result: [E] = fetch()
        return result.map { $0.toModel() }
    }
    
    func fetchOneById<E: NSManagedObject>(id: UUID) -> E? {
        return fetchOne(predicate: NSPredicate(format: "id = %@", id as NSUUID))
    }
    
    func fetchOneById<M, E>(id: UUID) -> M? where M : EntityConverting, M == E.M, E : ModelConverting, E == M.E {
        let result: E? = fetchOneById(id: id)
        return result?.toModel()
    }
    
    func upsert<E, M>(model: M) where E == M.E, M : EntityConverting, M : Identifiable<UUID> {
        if let fetchedEntity: E = fetchOneById(id: model.id) {
            
            let entity = model.toEntity()
            
            let description = NSEntityDescription.entity(
                forEntityName: .init(describing: E.self),
                in: context
            )
            
            let entityKeys: [String] = if let attributes = description?.attributesByName { Array(attributes.keys) } else { [] }
            
            for key in entityKeys {
                fetchedEntity.setValue(entity.value(forKey: key), forKey: key)
            }
            
            let relationshipKeys: [String] = if let relations = description?.relationshipsByName { Array(relations.keys) } else { [] }
            
            for key in relationshipKeys {
                fetchedEntity.setValue(entity.value(forKey: key), forKey: key)
            }
            
            if (entity.objectID != fetchedEntity.objectID) {
                context.delete(entity)
            }
        }
        else {
            // To create entity to be persisted
            _ = model.toEntity()
        }
        save()
    }
    
    func delete<T: NSManagedObject>(entity: T) {
        context.delete(entity)
        save()
    }
}

internal extension CoreDataManager {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Cannot save MOC: \(error.localizedDescription)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptions: [NSSortDescriptor]? = nil
    ) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        if predicate != nil {
            request.predicate = predicate
        }
        if let sortDescriptions = sortDescriptions {
            request.sortDescriptors = sortDescriptions
        }
        var lines: [T] = []
        
        do {
            lines = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        
        return lines
    }
    
    func fetchOne<T: NSManagedObject>(
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
