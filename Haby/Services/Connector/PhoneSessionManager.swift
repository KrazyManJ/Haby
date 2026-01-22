import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate, PhoneSessionManaging, ObservableObject {
    
    static let shared = PhoneSessionManager()
    private var dataManager: Injected<DataManaging> = .init()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("phone session active: \(activationState == .activated)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    // sync all upcoming?UI
    func syncAllHabitsToWatch() {
            // Run on background thread to avoid freezing UI during fetch
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let dailyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForToday()
                let weeklyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForWeek()
                let dailyAmountHabits = self.dataManager.wrappedValue.getAmountHabitsForToday()
                let weeklyAmountHabits =
                self.dataManager.wrappedValue.getAmountHabitsForWeek()
                
                let allHabits = dailyTimeHabits + weeklyTimeHabits + dailyAmountHabits + weeklyAmountHabits
                
                self.sendHabits(habits: allHabits)
            }
        }
    
        func sendHabits(habits: [HabitDefinition]) {
            guard WCSession.default.activationState == .activated else {
                WCSession.default.activate()
                return
            }
            
            let payload = ["habitList": habits.map { $0.convertToWatchData() }]
            
            do {
                try WCSession.default.updateApplicationContext(payload)
                print("Global Sync: Sent \(habits.count) habits to Watch")
            } catch {
                print("Global Sync Error: \(error.localizedDescription)")
            }
        }
}
