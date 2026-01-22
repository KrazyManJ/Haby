import WatchConnectivity
import Foundation
import Combine

class WatchSessionManager: NSObject, WCSessionDelegate, WatchSessionManaging, ObservableObject {
    //private var session: WCSession
    @Published var habits: [HabitDefinition] = []
    //private var dataManager: DataManaging
    static let shared = WatchSessionManager()
    
    override init(){
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("activation status: \(activationState == .activated ? "active" : "inactive")")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print ("received context: \(applicationContext)")
        if let rawHabitArray = applicationContext["habitList"] as? [[String: Any]] {
            DispatchQueue.main.async {
                self.habits = rawHabitArray.map {
                    $0.convertToPhoneData()
                }
                print ("Watch received \(self.habits.count) habits")
            }
        }
    }
    

}

