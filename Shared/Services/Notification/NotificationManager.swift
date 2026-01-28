import UserNotifications
import Combine

class NotificationManager : NSObject, NotificationManaging, UNUserNotificationCenterDelegate {
    
    private let center = UNUserNotificationCenter.current()
    
    var selectedHabitId = CurrentValueSubject<String?, Never>(nil)
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let habitId = userInfo["habitId"] as? String {
            selectedHabitId.send(habitId)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("There was an error requestion notification permission: \(error)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func scheduleNotificationForHabit(habit: HabitDefinition) {
        
        let dateComponents = habit.getNotificationDateComponents()
        
        let content = UNMutableNotificationContent()
        switch habit.data {
        case .Amount:
            content.title = "Track your \(habit.name)"
            content.body = "Don't forget to log your progress today!"
            
        case .Deadline:
            content.title = "Deadline: \(habit.name)"
            content.body = "Make sure to complete this before your deadline."
            
        case .OnTime:
            content.title = "It's time for \(habit.name)"
            content.body = "This is your scheduled time to start."
        }
        content.sound = .default
        
        content.userInfo = ["habitId": habit.id.uuidString]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request)
        print("Set notification to \(habit.id.uuidString)")
    }
    
    func removeNotificationForHabit(habit: HabitDefinition) {
        center.removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
    
    func removeAllReminders() {
        center.removeAllPendingNotificationRequests()
    }
}


extension HabitDefinition {
    func getNotificationDateComponents() -> DateComponents {
        var components = DateComponents()
        
        switch data {
        case .Amount:
            components.hour = 17
            components.minute = 0
            
        case .Deadline(let habitData):
            let targetMinutes = habitData.minutesOfCompletionInFrequency - 60
            applyTime(from: targetMinutes, frequency: habitData.frequency, to: &components)
            
        case .OnTime(let habitData):
            let targetMinutes = habitData.minutesOfCompletionInFrequency - OnTimeHabitDefinitionData.VALID_TIME_RANGE_IN_MINUTES
            applyTime(from: targetMinutes, frequency: habitData.frequency, to: &components)
        }
        
        return components
    }
    
    private func applyTime(from totalMinutes: Int, frequency: HabitFrequency, to components: inout DateComponents) {
        let minutesInDay = 1440
        let minutesInWeek = 10080
        
        if frequency == .Weekly {
            let normalizedMinutes = (totalMinutes % minutesInWeek + minutesInWeek) % minutesInWeek
            
            let dayIndexFromMonday = normalizedMinutes / minutesInDay
            components.weekday = dayIndexFromMonday == 6 ? 1 : dayIndexFromMonday + 2
            
            let dayMinutes = normalizedMinutes % minutesInDay
            components.hour = dayMinutes / 60
            components.minute = dayMinutes % 60
        } else {
            let normalizedMinutes = (totalMinutes % minutesInDay + minutesInDay) % minutesInDay
            components.hour = normalizedMinutes / 60
            components.minute = normalizedMinutes % 60
        }
    }
}
