
internal extension DIContainer {
    func registerDependencies() {
        register(DataManaging.self) {
            CoreDataManager()
        }
        register(StepsManaging.self) {
            HealthKitStepsManager()
        }
    }
}
