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
        DispatchQueue.main.async {
            print("Phone session Activated: \(activationState == .activated)")
        }
        
        if activationState == .activated {
            print("Phone session active, performing initial cold-start sync...")
            self.syncAllHabitsToWatch()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    
    // does not sync only upcoming - it messes with records
    func syncAllHabitsToWatch() {
        // Run on background thread to avoid freezing UI during fetch
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
//            let calendar = Calendar.current
//            let now = Date()
//            let hour = calendar.component(.hour, from: now)
//            let minute = calendar.component(.minute, from: now)
//            let currentMinutes = (hour * 60) + minute
            
            let dailyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForToday()
            let weeklyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForWeek()
            let dailyAmountHabits = self.dataManager.wrappedValue.getAmountHabitsForToday()
            let weeklyAmountHabits =
            self.dataManager.wrappedValue.getAmountHabitsForWeek()
            
            let timeHabits = dailyTimeHabits + weeklyTimeHabits
            
//            let upcomingTimeHabits = timeHabits.filter { habit in
//                guard let targetMinutes = habit.effectiveTimestamp else { return false }
//                
//                // grace period
//                return targetMinutes > (currentMinutes - 60)
//            }
            
//            let allHabits = upcomingTimeHabits + dailyAmountHabits + weeklyAmountHabits
            
            let allHabits = timeHabits + dailyAmountHabits + weeklyAmountHabits
            
            let todayRecords = self.dataManager.wrappedValue.getTodayRecords()
            let weekRecords = self.dataManager.wrappedValue.getWeekRecords()
            
            let allRecords = todayRecords + weekRecords
            
            print("Syncing to Watch: \(allHabits.count) habits, \(allRecords.count) records")
            
            self.sendDataToWatch(habits: allHabits, records: allRecords)
        }
    }
    
    func sendDataToWatch(habits: [HabitDefinition]? = nil, records: [HabitRecord]? = nil) {
        var payload: [String: Any] = [:]
        guard WCSession.default.activationState == .activated else {
            WCSession.default.activate()
            return
        }
        
        if let habits = habits {
            payload["habitList"] = habits.map { $0.convertToWatchData() }
        }
        
        if let records = records {
            payload["habitRecords"] = records.map { $0.convertToWatchData() }
        }
        
        guard !payload.isEmpty else { return }
        
        do {
            // updateApplciationContext overwrites the previous content -> safer to send everything
            try WCSession.default.updateApplicationContext(payload)
        } catch {
            print("Global Sync Error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String, action == "saveRecord" else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // fetch Definitions for reconstruction
            let dailyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForToday()
            let weeklyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForWeek()
            let dailyAmountHabits = self.dataManager.wrappedValue.getAmountHabitsForToday()
            let weeklyAmountHabits =
            self.dataManager.wrappedValue.getAmountHabitsForWeek()
            
            let allHabits = dailyTimeHabits + weeklyTimeHabits + dailyAmountHabits + weeklyAmountHabits
            
            if var newRecord = message.convertToRecord(using: allHabits) {
                newRecord.date = newRecord.date.onlyDate
                self.dataManager.wrappedValue.upsert(model: newRecord)
                print("Received and saved record for: \(newRecord.habitDefinition.name)")
            } else {
                print("Failed to convert message to record. Missing parent habit?")
            }
        }
    }
}

