import WatchConnectivity
import Foundation
import Combine

class WatchSessionManager: NSObject, WCSessionDelegate, WatchSessionManaging, ObservableObject {
    @Published var habits: [HabitDefinition] = []
    @Published var records: [HabitRecord] = []
    static let shared = WatchSessionManager()
    
    private var dataManager: Injected<DataManaging> = .init()
    
    private let kLastCleanupDate = "LastCleanupDate"
    
    override init(){
        super.init()
        loadLocalData()
        if !habits.isEmpty {
            print("🚨 GHOST DATA DETECTED: Found \(habits.count) habits already in Core Data on startup!")
        } else {
            print("✅ Core Data is clean.")
        }
        performDailyCleanup()
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
            print("📡 Received Context from Phone")
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                var parsedHabits: [HabitDefinition] = []
                var parsedRecords: [HabitRecord] = []
                
                if let rawHabits = applicationContext["habitList"] as? [[String: Any]] {
                    parsedHabits = rawHabits.map { $0.convertToPhoneData() }
                }
                
                // Note: We need the habits we just parsed to link the records correctly!
                if let rawRecords = applicationContext["habitRecords"] as? [[String: Any]] {
                    // If we have new habits from phone, use them. Otherwise use local habits.
                    let referenceHabits = parsedHabits.isEmpty ? self.habits : parsedHabits
                    
                    parsedRecords = rawRecords.compactMap {
                        $0.convertToRecord(using: referenceHabits)
                    }
                }
                
                self.saveIncomingData(habits: parsedHabits, records: parsedRecords)
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
        let now = Date()
        
        let targetDate = (habit.frequency == .Weekly) ? now.startOfWeek : Calendar.current.startOfDay(for: now)
        
        if let index = records.firstIndex(where: { $0.habitDefinition.id == habit.id
            && Calendar.current.isDate($0.date, inSameDayAs: targetDate)}) {
        // --- UPDATE EXISTING ---
                if case .Amount(let data) = records[index].data {
                    let newValue = data.value + amount
                    records[index].data = .Amount(data: .init(value: newValue))
                    
                    // Sync updated record
                    syncRecordToPhone(records[index])
                }
            } else {
                // --- CREATE NEW ---
                let newRecord = HabitRecord(
                    id: UUID(),
                    date: targetDate, // ⚠️ Normalized Date
                    habitDefinition: habit,
                    data: .Amount(data: .init(value: amount))
                )
                records.append(newRecord)
                syncRecordToPhone(newRecord)
            }
        }

    func checkHabit(_ habit: HabitDefinition) {
        guard !records.contains(where: { $0.habitDefinition.id == habit.id }) else { return }

        let now = Date()
            // 2. Determine Date & Time based on Frequency
        var recordDate: Date
        var minutesValue: Int
        
        if habit.frequency == .Weekly {
            // WEEKLY: Normalize to Start of Week (e.g., Monday 00:00)
            recordDate = now.startOfWeek
            // Calculate minutes elapsed since start of week (e.g., Wednesday Noon = ~3600 mins)
            minutesValue = now.minutesFromStartOfWeek()
        } else {
            // DAILY: Normalize to Start of Day (Today 00:00)
            recordDate = Calendar.current.startOfDay(for: now)
            // Calculate minutes elapsed since midnight
            minutesValue = now.minutesFromStartOfDay()
        }
        
        // 3. Create Data
        let recordData: HabitRecordData = (habit.data.type == .Deadline)
            ? .Deadline(data: .init(minutesOfCompletionInFrequency: minutesValue))
            : .OnTime(data: .init(minutesOfCompletionInFrequency: minutesValue))
        
        // 4. Create Record
        let newRecord = HabitRecord(
            id: UUID(),
            date: recordDate, // ⚠️ Normalized Date
            habitDefinition: habit,
            data: recordData
        )
        
        records.append(newRecord)
        syncRecordToPhone(newRecord)
    }
    
    private func loadLocalData() {
//        let dailyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForToday()
//        let weeklyTimeHabits = self.dataManager.wrappedValue.getTimeHabitsForWeek()
//        let dailyAmountHabits = self.dataManager.wrappedValue.getAmountHabitsForToday()
//        let weeklyAmountHabits =
//        self.dataManager.wrappedValue.getAmountHabitsForWeek()
//       
//        self.habits = dailyTimeHabits + weeklyTimeHabits + dailyAmountHabits + weeklyAmountHabits
        let allHabits = self.dataManager.wrappedValue.getAllHabits()
        
        self.habits = allHabits
        
        // B. Load Records (ONLY for Today)
        // This naturally handles the "New Day" logic.
        // If it's a new day, this returns [], giving you a fresh start.
    
    // get week records as well
        let dailyRecords = self.dataManager.wrappedValue.getTodayRecords()
        let weekRecords = self.dataManager.wrappedValue.getWeekRecords()
        
        //self.records = dataManager.wrappedValue.getTodayRecords()
        let allRecords = dailyRecords + weekRecords
        
        print("💾 Loaded from Watch Core Data: \(self.habits.count) habits, \(self.records.count) records")
    }
        
    private func saveIncomingData(habits: [HabitDefinition], records: [HabitRecord]) {
        let incomingHabitIDs = Set(habits.map { $0.id })
        let existingHabits = dataManager.wrappedValue.getAllHabits()
        let habitsToDelete = existingHabits.filter { !incomingHabitIDs.contains($0.id) }
        
        for habit in habitsToDelete {
            print("🗑️ Sync: Deleting obsolete habit '\(habit.name)' from Watch")
            if let entity: HabitDefinitionEntity = dataManager.wrappedValue.fetchOneById(id: habit.id) {
                dataManager.wrappedValue.delete(entity: entity)
            }
        }
        
        for habit in habits {
            dataManager.wrappedValue.upsert(model: habit)
        }
        
        for record in records {
            dataManager.wrappedValue.upsert(model: record)
        }
        
        DispatchQueue.main.async {
            self.loadLocalData()
        }
    }
    
    private func performDailyCleanup() {
        let defaults = UserDefaults.standard
        let lastCleanup = defaults.object(forKey: kLastCleanupDate) as? Date ?? Date.distantPast
        
        // If the last cleanup wasn't "Today"
        if !Calendar.current.isDateInToday(lastCleanup) {
            print("New day detected! Cleaning up old records...")
            let calendar = Calendar.current
            let today = Date()
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
                
                let startOfYesterday = calendar.startOfDay(for: yesterday)
                
                dataManager.wrappedValue.deleteRecordsBefore(date: startOfYesterday)
            }
            // Delete records older than yesterday (Keep yesterday's just in case of sync issues)
            // You'll need a delete helper in your DataManager, e.g., deleteRecordsBefore(date:)
            // dataManager.wrappedValue.deleteOldRecords()
            
            defaults.set(Date(), forKey: kLastCleanupDate)
        }
    }
}

