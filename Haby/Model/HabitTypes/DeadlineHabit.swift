import Foundation

struct DeadlineHabitDefinitionData : HabitDataDefining, HabitRecordValidating, Hashable {
    var frequency: HabitFrequency
    var minutesOfCompletionInFrequency: Int
    
    func isSatisfied(by recordData: DeadlineHabitRecordData) -> Bool {
        return self.minutesOfCompletionInFrequency >= recordData.minutesOfCompletionInFrequency
    }
}

struct DeadlineHabitRecordData: HabitDataRecording {
    var date: Date
    var minutesOfCompletionInFrequency: Int
}
