import SwiftUI

extension CoreDataManager {
    func insertMockupData() {
        
        let yoga = HabitDefinition(
            id: UUID(),
            name: "Yoga",
            icon: "figure.yoga",
            type: .Deadline,
            frequency: .Daily,
            targetTimestamp: 60 * 17 // 17:00
        )
        
        let pill = HabitDefinition(
            id: UUID(),
            name: "Take medication",
            icon: "pill",
            type: .OnTime,
            frequency: .Daily,
            targetTimestamp: 60 * 9 // 9:00
        )
        
        let walk = HabitDefinition(
            id: UUID(),
            name: "Walk",
            icon: "figure.walk",
            type: .Amount,
            frequency: .Daily,
            targetValue: 10000,
            targetValueUnit: .Steps
        )
        
        let habits = [yoga,pill,walk]
        
        _ = habits.map { $0.toEntity()}
        _ = createMockHabitRecords(for: habits).map { $0.toEntity()}
        
        save()
    }
    
    func createMockHabitRecords(for habits: [HabitDefinition]) -> [HabitRecord] {
        var records = [HabitRecord]()
        let calendar = Calendar.current
        let today = Date().onlyDate

        let validDaysOffsets = [0, 1, 2, 5]
        

        for habit in habits {
            for offset in validDaysOffsets {
                let recordDate = today.daysAgo(offset)

                var timestamp: Int? = nil
                var value: Float? = nil

                switch habit.type {
                case .Deadline, .OnTime:
                    timestamp = habit.targetTimestamp
                    
                case .Amount:
                    if let targetVal = habit.targetValue {
                        value = targetVal
                    }
                }

                let record = HabitRecord(
                    id: UUID(),
                    date: recordDate,
                    timestamp: timestamp,
                    value: value,
                    habitDefinition: habit
                )
                print(habit.name, recordDate, timestamp)
                records.append(record)
            }
        }
        
        return records
    }
}
