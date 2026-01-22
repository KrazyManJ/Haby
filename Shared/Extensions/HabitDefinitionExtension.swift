import SwiftUI

extension HabitDefinition {
    var effectiveTimestamp: Int? {
        switch self.data {
        case .OnTime(let data):
            return data.minutesOfCompletionInFrequency
        case .Deadline(let data):
            return data.minutesOfCompletionInFrequency
        case .Amount:
            return nil
        }
    }
}

