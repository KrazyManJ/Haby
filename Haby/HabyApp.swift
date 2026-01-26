
import SwiftUI

@main
struct HabyApp: App {
    
    @Injected private var dataManager: DataManaging
    
    @Injected private var notificationManager: NotificationManaging
    
    init() {
        _ = notificationManager
        if dataManager.isEmpty {
            dataManager.insertMockupData()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
