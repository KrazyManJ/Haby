import WatchConnectivity

protocol WatchSessionManaging {
    func sendRecordData(record: HabitRecord)
    func sendRecordRemoval(recordId: UUID)
}

