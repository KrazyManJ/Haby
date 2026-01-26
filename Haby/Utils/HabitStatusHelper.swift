import Foundation

import Foundation

struct HabitStatusHelper {
    let requirementString: String
    let isOverdue: Bool
    var isCompleted: Bool
    let progressString: String
    
    init(habit: HabitDefinition, record: HabitRecord?) {
        self.isCompleted = record != nil && (record?.isSatisfied ?? false)
        
        if case .Amount(let data) = habit.data {
            self.isOverdue = false
            
            let currentValue: Float
            if let recordData = record?.data, case .Amount(let rData) = recordData {
                currentValue = rData.value
            } else {
                currentValue = 0
            }
            
            let isTargetReached = currentValue >= data.amount
            let actuallyCompleted = isTargetReached
            
            let unitAbbr = data.unit.abbreviation
            let currStr = currentValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", currentValue) : String(format: "%.1f", currentValue)
            let targetStr = data.amount.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", data.amount) : String(format: "%.1f", data.amount)
            
            self.requirementString = "\(targetStr) \(unitAbbr)"
            self.progressString = "\(currStr)/\(targetStr) \(unitAbbr)"
            
            self.isCompleted = isTargetReached
        }
        
        else {
            let timestamp: Int
            if case .Deadline(let d) = habit.data { timestamp = d.minutesOfCompletionInFrequency }
            else if case .OnTime(let d) = habit.data { timestamp = d.minutesOfCompletionInFrequency }
            else { timestamp = 0 }
            
            let targetDate = Date.fromMinutesTimestamp(timestamp: timestamp)
            
            self.isOverdue = (targetDate < Date()) && !self.isCompleted
            
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            self.requirementString = formatter.localizedString(for: targetDate, relativeTo: Date())
            
            self.progressString = self.isCompleted ? "Done" : self.requirementString
        }
    }
}
