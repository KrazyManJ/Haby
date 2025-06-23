
import SwiftUI

@main
struct HabyApp: App {
    
    var dataManaging: Injected<DataManaging> = .init()
    
    init() {
        if dataManaging.wrappedValue.isEmpty {
            dataManaging.wrappedValue.insertMockupData()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
