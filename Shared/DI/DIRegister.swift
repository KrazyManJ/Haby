
internal extension DIContainer {
    func registerDependencies() {
        register(DataManaging.self) {
            CoreDataManager()
        }
        register(HealthManaging.self) {
            HealthManager()
        }
    }
}
