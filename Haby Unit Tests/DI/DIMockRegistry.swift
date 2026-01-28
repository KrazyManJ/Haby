@testable import Haby

internal extension DIContainer {
    func registerDependencies() {
        print("Run overrride")
        register(DataManaging.self) {
            CoreDataManager(inMemory: true)
        }
    }
}
