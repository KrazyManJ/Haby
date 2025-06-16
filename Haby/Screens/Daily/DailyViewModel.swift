
import SwiftUI

@Observable
class DailyViewModel: ObservableObject {
    var state: DailyViewState = DailyViewState()
    var dataManaging: Injected<DataManaging> = .init()
    
    func updateMood(mood: Mood) {
        dataManaging.wrappedValue.upsert(model: state.todayMoodData)
    }
    
    func getTodayMood() {
        if let todayMoodDataEntity = dataManaging.wrappedValue.getMoodRecordByDate(date: Date().onlyDate) {
            state.todayMoodData = todayMoodDataEntity.toModel()
        }
    }
    
    func isTodayMoodSaved() -> Bool {
        let moodSavedFromDate = dataManaging.wrappedValue.getMoodRecordByDate(date: Date().onlyDate)
        return moodSavedFromDate != nil
    }
}
