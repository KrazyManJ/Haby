import UserNotifications

protocol NotificationManaging {
    func requestPermission(completion: @escaping (Bool) -> Void)
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
    func scheduleNotificationForHabit(habit: HabitDefinition)
    func removeNotificationForHabit(habit: HabitDefinition)
    func removeAllReminders()
}
