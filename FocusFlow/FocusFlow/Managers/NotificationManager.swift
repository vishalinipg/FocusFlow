import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("NotificationManager: Permission error – \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Daily Reminder
    func scheduleDailyReminder() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            // Remove old reminders before scheduling a new one
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focusflow.daily.reminder"])

            let content = UNMutableNotificationContent()
            content.title = "Don't break your streak 🔥"
            content.body = "Complete at least one focus session today!"
            content.sound = .default
            content.badge = 1

            // Fire daily at 20:00 (8 PM)
            var dateComponents = DateComponents()
            dateComponents.hour = 20
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "focusflow.daily.reminder",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("NotificationManager: Failed to schedule – \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Cancel All
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
