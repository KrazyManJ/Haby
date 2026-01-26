import WatchConnectivity
import Foundation
import Combine

class WatchSessionManager: NSObject, WCSessionDelegate, WatchSessionManaging {
    
    @Injected private var dataManager: DataManaging
    
    private var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("received")
        guard let action = applicationContext["action"] as? String else {
            return
        }
        
        if action == "sync" {
            
            let decoder = JSONDecoder()
            
            guard
                let habitsData = applicationContext["habits"] as? Data,
                let habits = try? decoder.decode([HabitDefinition].self, from:habitsData),
                let recordsData = applicationContext["records"] as? Data,
                let records = try? decoder.decode([HabitRecord].self, from: recordsData)
            else {
                fatalError("No decode mno fun")
            }
            
            dataManager.deleteAll(HabitRecordEntity.self)
            dataManager.deleteAll(HabitDefinitionEntity.self)
            habits.forEach { dataManager.upsert(model: $0) }
            records.forEach { dataManager.upsert(model: $0) }
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
            fatalError("Failed to send message: \(error.localizedDescription)")
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
    }
    
    private func refreshUI() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reloadHabits, object: nil)
        }
    }
}

