import Foundation

protocol HabitManaging {
    func calculateCurrentStreak() -> Int
    func getDatesWithAllSatisfiedHabits() -> [Date]
}
