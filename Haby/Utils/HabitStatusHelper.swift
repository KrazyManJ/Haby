import Foundation

import Foundation

struct HabitStatusHelper {
    let requirementString: String
    let isOverdue: Bool
    var isCompleted: Bool
    let progressString: String // New: "500 / 2000" or "Done"
    
    init(habit: HabitDefinition, record: HabitRecord?) {
        // Default state
        self.isCompleted = record != nil && (record?.isSatisfied ?? false) // Assuming you have this logic or similar
        
        // --- 1. AMOUNT HABITS ---
        if case .Amount(let data) = habit.data {
            self.isOverdue = false
            
            // Get current value from record, or 0 if no record exists
            // We need to extract the value from the record's data enum
            let currentValue: Float
            if let recordData = record?.data, case .Amount(let rData) = recordData {
                currentValue = rData.value
            } else {
                currentValue = 0
            }
            
            // Completion Logic for Amount: Is current >= target?
            let isTargetReached = currentValue >= data.amount
            // Update isCompleted based on value (override standard check if needed)
            let actuallyCompleted = isTargetReached
            
            // Formatting
            let unitAbbr = data.unit.abbreviation
            let currStr = currentValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", currentValue) : String(format: "%.1f", currentValue)
            let targetStr = data.amount.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", data.amount) : String(format: "%.1f", data.amount)
            
            self.requirementString = "\(targetStr) \(unitAbbr)"
            self.progressString = "\(currStr)/\(targetStr) \(unitAbbr)"
            
            // Redefine isCompleted for internal use in filtering
            // (We use a let in init, so we must set self.isCompleted properly above or use a local var)
            // Let's assume 'isCompleted' is strictly "Is it done?"
            self.isCompleted = isTargetReached
        }
        
        // --- 2. TIME HABITS (Deadline / OnTime) ---
        else {
            // Helper to get timestamp
            let timestamp: Int
            if case .Deadline(let d) = habit.data { timestamp = d.minutesOfCompletionInFrequency }
            else if case .OnTime(let d) = habit.data { timestamp = d.minutesOfCompletionInFrequency }
            else { timestamp = 0 }
            
            let targetDate = Date.fromMinutesTimestamp(timestamp: timestamp)
            
            // Overdue if NOW > Target AND it is NOT completed
            self.isOverdue = (targetDate < Date()) && !self.isCompleted
            
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            self.requirementString = formatter.localizedString(for: targetDate, relativeTo: Date())
            
            self.progressString = self.isCompleted ? "Done" : self.requirementString
        }
    }
}
