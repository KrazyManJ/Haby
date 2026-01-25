import SwiftUI

extension CoreDataManager {
    func insertMockupData() {
        
        let createdAt = Date().onlyDate.daysAgo(50)
        print("Data created at", createdAt)
        let notificationManager: Injected<NotificationManaging> = .init()
        
        let yoga = HabitDefinition(
            name: "Yoga",
            icon: "figure.yoga",
            creationDate: createdAt,
            type: .Deadline,
            frequency: .Daily,
            targetTimestamp: 60 * 17, // 17:00
            data: .Deadline(data: .init(
                frequency: .Daily, minutesOfCompletionInFrequency: 60 * 17
            ))
        )
        
        // for testing grace period on watch
        let yoga2 = HabitDefinition(
            name: "Yoga",
            icon: "figure.yoga",
            creationDate: createdAt,
            type: .Deadline,
            frequency: .Daily,
            targetTimestamp: 60 * 23,
            data: .Deadline(data: .init(
                frequency: .Daily, minutesOfCompletionInFrequency: 60 * 23
            ))
        )
        
        let pill = HabitDefinition(
            id: UUID(),
            name: "Take medication",
            icon: "pill",
            creationDate: createdAt,
            type: .OnTime,
            frequency: .Daily,
            targetTimestamp: 60 * 9, // 9:00
            data: .OnTime(data: .init(
                frequency: .Daily,
                minutesOfCompletionInFrequency: 60 * 9
            ))
        )
        
        let walk = HabitDefinition(
            id: UUID(),
            name: "Walk",
            icon: "figure.walk",
            creationDate: createdAt,
            type: .Amount,
            frequency: .Daily,
            targetValue: 10000,
            targetValueUnit: .Steps,
            data: .Amount(data: .init(frequency: .Daily, amount: 1000, unit: .Steps))
        )
        
        let journaling = HabitDefinition(
            id: UUID(),
            name: "Journaling",
            icon: "pencil.and.scribble",
            creationDate: createdAt,
            type: .Deadline,
            frequency: .Weekly,
            targetTimestamp: 60 * 9,
            data: .Deadline(data: .init(frequency: .Weekly, minutesOfCompletionInFrequency: 60 * 9))
        )
        
        let test = HabitDefinition(
            id: UUID(),
            name: "Workout",
            icon: "dumbbell",
            creationDate: createdAt,
            type: .Amount,
            frequency: .Weekly,
            targetValue: 10,
            targetValueUnit: .Hours,
            data: .Amount(data: .init(frequency: .Weekly, amount: 10, unit: .Hours))
        )
                
        let habits = [yoga,yoga2,pill,walk,journaling]
        
        for habit in habits {
            notificationManager.wrappedValue.scheduleNotificationForHabit(habit: habit)
        }
        
        _ = habits.map { $0.toEntity()}
        _ = createMockHabitRecords(for: habits).map { $0.toEntity()}
        _ = test.toEntity()
        _ = createMockMoodRecords().map({ $0.toEntity() })
        
//         Habit that will break streak if not correct coded :]
        _ = HabitDefinition(
            name: "Studying",
            icon: "book",
            creationDate: Date().onlyDate,
            type: .Amount,
            frequency: .Daily,
            targetValue: 90,
            targetValueUnit: .Minutes,
            data: .Amount(data: .init(frequency: .Daily, amount: 90, unit: .Minutes))
        ).toEntity()
        
        save()
    }
    
    func createMockHabitRecords(for habits: [HabitDefinition]) -> [HabitRecord] {
        var records = [HabitRecord]()
        let today = Date().onlyDate

        let validDaysOffsets = (0...48)+[50]
        

        for habit in habits {
            for offset in validDaysOffsets {
                let recordDate = today.daysAgo(offset)

                var timestamp: Int? = nil
                var value: Float? = nil

                var recordData: HabitRecordData {
                    switch habit.data {
                    case .Deadline(let data):
                        timestamp = data.minutesOfCompletionInFrequency
                        return .Deadline(data: .init(
                            date: recordDate,
                            minutesOfCompletionInFrequency: data.minutesOfCompletionInFrequency)
                        )
                    case .OnTime(let data):
                        timestamp = data.minutesOfCompletionInFrequency
                        return .OnTime(data: .init(date: recordDate, minutesOfCompletionInFrequency: data.minutesOfCompletionInFrequency))
                    case .Amount(let data):
                        value = data.amount
                        return .Amount(data: .init(date: recordDate, value: data.amount))
                    }
                }
                

                let record = HabitRecord(
                    date: recordDate,
                    timestamp: timestamp,
                    value: value,
                    habitDefinition: habit,
                    data: recordData
                )
                records.append(record)
            }
        }
        return records
    }
    
    func createMockMoodRecords() -> [MoodRecord] {
        var records: [MoodRecord] = []
        let today = Date().onlyDate
        
        let validDaysOffsets = 0...5
        
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
