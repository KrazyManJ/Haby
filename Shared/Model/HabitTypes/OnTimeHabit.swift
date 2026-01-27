import Foundation

struct OnTimeHabitDefinitionData : HabitDataDefining, HabitRecordValidating, Hashable {
    var frequency: HabitFrequency
    var minutesOfCompletionInFrequency: Int
    
    static let VALID_TIME_RANGE_IN_MINUTES = 5
    
    func isSatisfied(by recordData: OnTimeHabitRecordData) -> Bool {
        
        let ON_TIME_HABIT_MINUTES_TIME_RANGE = 5
        
        let startRange = self.minutesOfCompletionInFrequency - ON_TIME_HABIT_MINUTES_TIME_RANGE
        let endRange = self.minutesOfCompletionInFrequency + ON_TIME_HABIT_MINUTES_TIME_RANGE
        
        return (startRange...endRange).contains(recordData.minutesOfCompletionInFrequency)
    }
}

struct OnTimeHabitRecordData : HabitDataRecording {
    var date: Date
    var minutesOfCompletionInFrequency: Int
}
