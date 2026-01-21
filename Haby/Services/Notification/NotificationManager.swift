import UserNotifications

extension HabitDefinition {
    func toNotificationDateComponent() -> DateComponents {
        var component = DateComponents()
        if self.type == .Amount {
            component.hour = 20
            component.minute = 0
        }
        if let timestamp = targetTimestamp {
            let hour = Int(timestamp / 60)
            let minutes = timestamp % 60
            if self.type == .OnTime {
                component.hour = hour
                component.minute = minutes - 5
            }
            else if self.type == .Deadline {
                component.hour = hour - 1
                component.minute = minutes
            }
            if self.frequency == .Weekly {
                component.weekday = ((timestamp / 1440 + 1) % 7) + 1
            }
        }
        return component
    }
}


class NotificationManager : NotificationManaging {
    
    private let center = UNUserNotificationCenter.current()
    
    
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
        
        let dateComponents = habit.toNotificationDateComponent()
        
        let content = UNMutableNotificationContent()
        content.title = "Do not forget on \(habit.name)!"
        content.body = "Body"
        content.sound = .default
        
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
    }
    
    func removeNotificationForHabit(habit: HabitDefinition) {
        center.removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
    
    func removeAllReminders() {
        center.removeAllDeliveredNotifications()
    }
}
