import UserNotifications

@MainActor
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    var onConfirm: (() -> Void)?
    var onSnooze: (() -> Void)?

    private override init() {
        super.init()
    }

    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("通知权限请求失败: \(error)")
            }
        }
        registerCategories()
    }

    private func registerCategories() {
        let confirmAction = UNNotificationAction(
            identifier: Constants.confirmActionID,
            title: "知道了",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: Constants.snoozeActionID,
            title: "稍后提醒",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Constants.notificationCategoryID,
            actions: [confirmAction, snoozeAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func sendReminder(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "休息提醒"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = Constants.notificationCategoryID

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "rest-reminder-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error)")
            }
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionID = response.actionIdentifier
        Task { @MainActor in
            switch actionID {
            case Constants.confirmActionID, UNNotificationDefaultActionIdentifier:
                onConfirm?()
            case Constants.snoozeActionID:
                onSnooze?()
            default:
                break
            }
        }
        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
