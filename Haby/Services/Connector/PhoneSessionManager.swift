import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate, PhoneSessionManaging {
    
    private var session: WCSession
    
    @Injected private var dataManager: DataManaging
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
        try? self.session.updateApplicationContext([:])
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    
    func syncAllHabitsToWatch() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let allHabits = dataManager.getAllHabits()
            
            let todayRecords = dataManager.getTodayRecords()
            let weekRecords = dataManager.getWeekRecords()
            
            let allRecords = todayRecords + weekRecords
            
            let encoder = JSONEncoder()
            
            let message: [String: Any] = [
                "action": "sync",
                "habits": try! encoder.encode(allHabits),
                "records": try! encoder.encode(allRecords)
            ]
            
            
            print("Syncing to Watch: \(allHabits.count) habits, \(allRecords.count) records")
            
            do {
                try session.updateApplicationContext(message)
            } catch {
                print("Sync error: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String else {
            return
        }
        
        let decoder = JSONDecoder()
        
        if action == "recordUpdate" {
            guard
                let recordData = message["record"] as? Data,
                let record = try? decoder.decode(HabitRecord.self, from: recordData)
            else {
                fatalError("Nono encode bade")
            }
            
            self.dataManager.upsert(model: record)
            notifyUI()
            syncAllHabitsToWatch()
        }
        else if action == "recordDelete" {
            guard
                let recordId = message["recordId"] as? String,
                let recordUUID = UUID(uuidString: recordId)
            else {
                fatalError("Cannot decode recordDelete action")
            }
            
            self.dataManager.delete(entity: dataManager.fetchOneById(id: recordUUID)!)
            notifyUI()
            syncAllHabitsToWatch()
        }
    }
    
    private func notifyUI() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reloadHabits, object: nil)
            self.syncAllHabitsToWatch()
        }
    }
}

