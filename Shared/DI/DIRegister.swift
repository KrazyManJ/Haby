
internal extension DIContainer {
    func registerDependencies() {
        register(DataManaging.self) {
            CoreDataManager()
        }
        register(HealthManaging.self) {
            HealthManager()
        }
        register(NotificationManaging.self) {
            NotificationManager()
        }
        register(HabitManaging.self) {
            HabitManager()
        }
        #if os(iOS)
        register(PhoneSessionManaging.self) {
            PhoneSessionManager()
        }
        #endif
        #if os(watchOS)
        register(WatchSessionManaging.self) {
            WatchSessionManager()
        }
        #endif
    }
}
