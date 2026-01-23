import UserNotifications

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
        
        let dateComponents = habit.getNotificationDateComponents()
        
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
