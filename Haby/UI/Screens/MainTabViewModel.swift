
import SwiftUI
import Combine

@Observable
class MainTabViewModel {
    
    var state = MainTabViewState()
    
    private var cancellables = Set<AnyCancellable>()
    
    @ObservationIgnored @Injected private var habitManager: HabitManaging
    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    @ObservationIgnored @Injected private var dataManager: DataManaging
    
    init() {
        setupNotificationSubscription()
    }
    
    private func setupNotificationSubscription() {
        notificationManager.selectedHabitId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] habitIdString in
                guard let self = self,
                      let idString = habitIdString,
                      let uuid = UUID(uuidString: idString) else { return }
                self.state.habitToShowOnNavigation = dataManager.fetchOneById(id: uuid)
                
                self.notificationManager.selectedHabitId.send(nil)
            }
            .store(in: &cancellables)
    }
    
    func fetchStreak() {
        state.streak = habitManager.calculateCurrentStreak()
    }
}
