import SwiftUI

extension CoreDataManager {
    func insertMockupData() {
        
        let createdAt = Date().onlyDate.daysAgo(5)
        
        let yoga = HabitDefinition(
            id: UUID(),
            name: "Yoga",
            icon: "figure.yoga",
            creationDate: createdAt,
            type: .Deadline,
            frequency: .Daily,
            targetTimestamp: 60 * 17 // 17:00
        )
        
        let pill = HabitDefinition(
            id: UUID(),
            name: "Take medication",
            icon: "pill",
            creationDate: createdAt,
            type: .OnTime,
            frequency: .Daily,
            targetTimestamp: 60 * 9 // 9:00
        )
        
        let walk = HabitDefinition(
            id: UUID(),
            name: "Walk",
            icon: "figure.walk",
            creationDate: createdAt,
            type: .Amount,
            frequency: .Daily,
            targetValue: 10000,
            targetValueUnit: .Steps
        )
        
        let journaling = HabitDefinition(
            id: UUID(),
            name: "Journaling",
            icon: "pencil.and.scribble",
            creationDate: createdAt,
            type: .Deadline,
            frequency: .Weekly,
            targetTimestamp: 60 * 9
        )
        
        let test = HabitDefinition(
            id: UUID(),
            name: "Workout",
            icon: "dumbbell",
            creationDate: createdAt,
            type: .Amount,
            frequency: .Weekly,
            targetValue: 10,
            targetValueUnit: .Steps
        )
                
        let habits = [yoga,pill,walk,journaling]
        
        _ = habits.map { $0.toEntity()}
        _ = createMockHabitRecords(for: habits).map { $0.toEntity()}
        _ = test.toEntity()
        _ = createMockMoodRecords().map({ $0.toEntity() })
        
        // Habit that will break streak if not correct coded :]
        _ = HabitDefinition(
            id: UUID(),
            name: "Studying",
            icon: "book",
            creationDate: Date(),
            type: .Amount,
            frequency: .Daily,
            targetValue: 90,
            targetValueUnit: .Minutes
        ).toEntity()
        
        save()
    }
    
    func createMockHabitRecords(for habits: [HabitDefinition]) -> [HabitRecord] {
        var records = [HabitRecord]()
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
                records.append(record)
            }
        }
        
        return records
    }
    
    func createMockMoodRecords() -> [MoodRecord] {
        var records: [MoodRecord] = []
        let today = Date().onlyDate
        
        let validDaysOffsets = [0, 1, 2, 5]
        
        for offset in validDaysOffsets {
            let recordDate = today.daysAgo(offset)
            records.append(MoodRecord(
                id: UUID(),
                date: recordDate,
                mood: Mood.allCases.randomElement()!
            ))
        }
        
        return records
    }
}
