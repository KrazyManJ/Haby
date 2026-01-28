@testable import Haby

internal extension DIContainer {
    func registerDependencies() {
        register(DataManaging.self) {
            CoreDataManager(inMemory: true)
        }
    }
}
