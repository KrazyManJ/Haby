import WatchConnectivity
import Foundation
import Combine

class WatchSessionManager: NSObject, WCSessionDelegate, WatchSessionManaging, ObservableObject {
    @Published var habits: [HabitDefinition] = []
    @Published var records: [HabitRecord] = []
    static let shared = WatchSessionManager()
    
    override init(){
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("activation status: \(activationState == .activated ? "active" : "inactive")")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        print ("received context: \(applicationContext)")
        DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
            
            if let rawHabits = applicationContext["habitList"] as? [[String: Any]] {
                self.habits = rawHabits.map { $0.convertToPhoneData() }
            }
            
            if let rawRecords = applicationContext["habitRecords"] as? [[String: Any]] {
                self.records = rawRecords.compactMap {
                    $0.convertToRecord(using: self.habits)
                }
                print("Watch Updated: \(self.records.count) records")
            }
        }
    }
    
    private func syncRecordToPhone(_ record: HabitRecord) {
        var payload = record.convertToWatchData()
        payload["action"] = "saveRecord"
        
        // METHOD A: Try instant message first (Best for live updates)
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("❌ Error sending message: \(error.localizedDescription)")
                // Optional: Fallback to transferUserInfo here if sending fails
            }
        }
        // todo missing session with transferUserInfo
        else {
            WCSession.default.transferUserInfo(payload)
            print("zzz Queued record for background transfer")
        }
    }

    func addAmount(to habit: HabitDefinition, amount: Float) {
        if let index = records.firstIndex(where: { $0.habitDefinition.id == habit.id }) {
            if case .Amount(let data) = records[index].data {
                let newValue = data.value + amount
                records[index].data = .Amount(data: .init(value: newValue))
                
                syncRecordToPhone(records[index])
            }
        }
        else {
            let newRecord = HabitRecord(
                id: UUID(),
                date: Date(),
                habitDefinition: habit,
                data: .Amount(data: .init(value: amount))
            )
            records.append(newRecord)
            syncRecordToPhone(newRecord)
        }
    }

    func checkHabit(_ habit: HabitDefinition) {
        guard !records.contains(where: { $0.habitDefinition.id == habit.id }) else { return }

        let calendar = Calendar.current
        let now = Date()
        let timestamp = (calendar.component(.hour, from: now) * 60) + calendar.component(.minute, from: now)
        
        let recordData: HabitRecordData = (habit.data.type == .Deadline)
            ? .Deadline(data: .init(minutesOfCompletionInFrequency: timestamp))
            : .OnTime(data: .init(minutesOfCompletionInFrequency: timestamp))
        
        let newRecord = HabitRecord(
            id: UUID(),
            date: Date(),
            habitDefinition: habit,
            data: recordData
        )
        
        records.append(newRecord)
        syncRecordToPhone(newRecord)
    }
}

