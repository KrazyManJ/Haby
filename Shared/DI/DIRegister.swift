
internal extension DIContainer {
    func registerDependencies() {
        register(DataManaging.self) {
            CoreDataManager()
        }
        register(HealthManaging.self) {
            HealthManager()
        }
        #if os(iOS)
        register(NotificationManaging.self) {
            NotificationManager()
        }
        #endif
    }
}
