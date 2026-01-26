
import SwiftUI
import Combine

@Observable
class MainTabViewModel {
    
    var state = MainTabViewState()
    
    private var cancellables = Set<AnyCancellable>()
    
    @ObservationIgnored @Injected private var habitManager: HabitManaging
    @ObservationIgnored @Injected private var notificationManager: NotificationManaging
    
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
                self.state.navigationPath = NavigationPath()
                
                self.state.navigationPath.append(uuid)
                
                self.notificationManager.selectedHabitId.send(nil)
            }
            .store(in: &cancellables)
    }
    
    func fetchStreak() {
        state.streak = habitManager.calculateCurrentStreak()
    }
}
