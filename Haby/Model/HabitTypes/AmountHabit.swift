import Foundation

struct AmountHabitDefinitionData : HabitDataDefining, HabitRecordValidating {
    var frequency: HabitFrequency
    var amount: Float
    var unit: AmountUnit
    
    func isSatisfied(by recordData: AmountHabitRecordData) -> Bool {
        return self.amount <= recordData.value
    }
}

struct AmountHabitRecordData: HabitDataRecording {
    var date: Date
    var value: Float
}
