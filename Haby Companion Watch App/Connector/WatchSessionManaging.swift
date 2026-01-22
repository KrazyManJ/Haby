import WatchConnectivity

protocol WatchSessionManaging {
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any])
}

