import WatchConnectivity
import Foundation
import Combine

class WatchSessionManager: NSObject, WCSessionDelegate, WatchSessionManaging {
    
    @Injected private var dataManager: DataManaging
    
    private var session: WCSession
    private var isSyncing: Bool = false
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let action = applicationContext["action"] as? String else {
            print("Canceling sync because one is already in process.")
            return
        }
        
        if action == "sync" {
            guard !self.isSyncing else {
                return
            }
            isSyncing = true
            
            let decoder = JSONDecoder()
            
            guard
                let habitsData = applicationContext["habits"] as? Data,
                let habits = try? decoder.decode([HabitDefinition].self, from:habitsData),
                let recordsData = applicationContext["records"] as? Data,
                let records = try? decoder.decode([HabitRecord].self, from: recordsData)
            else {
                fatalError("No decode mno fun")
            }
            
            print(habits.map {$0.name})
            dataManager.deleteAll(HabitRecordEntity.self)
            dataManager.deleteAll(HabitDefinitionEntity.self)
            habits.forEach {
                dataManager.upsert(model: $0)
            }
            records.forEach {
                dataManager.upsert(model: $0)
            }
            isSyncing = false
        }
        
        refreshUI()
    }
    
    func sendRecordData(record: HabitRecord) {
        guard session.isReachable else {
            return print("Session not reachable")
        }
        
        let encoder = JSONEncoder()
        
        let message: [String: Any] = [
            "action": "recordUpdate",
            "record": try! encoder.encode(record)
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message from watch: \(error.localizedDescription)")
        }
    }
    
    func sendRecordRemoval(recordId: UUID) {
        guard session.isReachable else {
            return print("Session not reachable")
        }
        
        let message: [String: Any] = [
            "action": "recordDelete",
            "recordId": recordId.uuidString
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message from watch: \(error.localizedDescription)")
        }
    }
    
    private func refreshUI() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reloadHabits, object: nil)
        }
    }
    
    func requestSyncWithMobile() {
        guard session.isReachable else {
            return print("Session not reachable")
        }
        
        session.sendMessage(["action": "sync"], replyHandler: nil) { error in
            print("Failed to send message from watch: \(error.localizedDescription)")
        }
    }
}

