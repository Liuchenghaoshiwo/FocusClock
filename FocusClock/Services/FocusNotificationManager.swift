import Foundation
import UserNotifications

enum FocusNotificationManager {
    private static let focusReminderIdentifier = "focus-session-reminder"

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    static func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    static func scheduleFocusReminder(taskName: String, minutes: Int) {
        let interval = max(TimeInterval(minutes * 60), 60)

        authorizationStatus { status in
            switch status {
            case .authorized, .provisional, .ephemeral:
                scheduleAuthorizedReminder(taskName: taskName, minutes: minutes, interval: interval)
            case .notDetermined:
                requestAuthorization { granted in
                    if granted {
                        scheduleAuthorizedReminder(taskName: taskName, minutes: minutes, interval: interval)
                    }
                }
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    static func cancelFocusReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [focusReminderIdentifier])
    }

    private static func scheduleAuthorizedReminder(taskName: String, minutes: Int, interval: TimeInterval) {
        cancelFocusReminder()

        let content = UNMutableNotificationContent()
        content.title = "专注提醒"
        content.body = "你已经专注 \(minutes) 分钟：\(taskName)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: focusReminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
