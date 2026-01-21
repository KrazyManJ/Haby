protocol NotificationManaging {
    func requestPermission(completion: @escaping (Bool) -> Void)
}
