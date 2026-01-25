

import SwiftUI
import HealthKit

@Observable
class OverviewViewModel: ObservableObject {
    var state = OverviewViewState()
    
    @ObservationIgnored @Injected private var dataManager: DataManaging
    @ObservationIgnored @Injected private var healthManager: HealthManaging
    @ObservationIgnored @Injected private var habitManager: HabitManaging
    
    func loadStepData() async {
        state.stepsToday = Int(await healthManager.fetchTodaySteps())
        print(state.stepsToday)
        state.monthlySteps =  await healthManager.fetchCurrentMonthStepData()
    }
    
    func selectDate(date: Date?) {
        if let date = date {
            state.selectedDateData = SelectedDateData(
                date: date,
                mood: dataManager.getMoodRecordByDate(date: date)?.toModel().mood,
                habitRecords: dataManager.getRecordsByDate(date: date),
                habitsForDate: dataManager.getHabitsForDate(date: date).filter { date.nextDay > $0.creationDate }
            )
        }
        else {
            state.selectedDateData = nil
        }
    }
    
    internal func wasHabitRecorded(habit: HabitDefinition, date: Date) -> Bool {
        let habitsRecords: [HabitRecord] = dataManager.getRecordsByDate(date: date)
        return habitsRecords.contains{ r in r.habitDefinition.id == habit.id }
    }
    
    internal func hasCompletedHabit(habit: HabitDefinition, date: Date) -> Bool {
        let habitsRecords: [HabitRecord] = dataManager.getRecordsByDate(date: date)
        
        if let record = habitsRecords.first(where: { r in
            r.habitDefinition.id == habit.id
        }) {
            return record.isSatisfied
        }
        return false
    }
    
    internal func hasAllHabitsInDay(date: Date) -> Bool {
        let habits = dataManager.getHabitsForDate(date: date)
        
        return habits
            .filter { date.nextDay > $0.creationDate }
            .allSatisfy { hasCompletedHabit(habit: $0, date: date) }
    }
    
    func loadCompletedDates() {
        state.completedDates.removeAll()
        state.moodRecords = dataManager.fetch()
        state.completedDates = Set(habitManager.getDatesWithAllSatisfiedHabits())
        state.streak = habitManager.calculateCurrentStreak()
        DispatchQueue.main.async {
        Task {
                await self.loadStepData()
            }
        }
    }
}
