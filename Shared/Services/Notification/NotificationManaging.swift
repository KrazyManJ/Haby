import UserNotifications
import Combine

protocol NotificationManaging {
    var selectedHabitId: CurrentValueSubject<String?, Never> { get }
    
    func requestPermission(completion: @escaping (Bool) -> Void)
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
    func scheduleNotificationForHabit(habit: HabitDefinition)
    func removeNotificationForHabit(habit: HabitDefinition)
    func removeAllReminders()
}
