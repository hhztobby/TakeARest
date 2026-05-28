import Foundation

enum Constants {
    // 默认时间（秒）
    static let defaultRemindInterval: TimeInterval = 45 * 60       // 45 分钟
    static let defaultRepeatInterval: TimeInterval = 2 * 60        // 2 分钟
    static let defaultSnoozeDelay: TimeInterval = 10 * 60          // 10 分钟
    static let defaultRestThreshold: TimeInterval = 30             // 30 秒

    // 通知标识符
    static let notificationCategoryID = "REST_REMINDER"
    static let confirmActionID = "CONFIRM_REST"
    static let snoozeActionID = "SNOOZE_REST"

    // 默认提醒文案
    static let defaultMessages = [
        "该休息了！站起来活动一下吧",
        "眼睛该休息了，看看远处吧",
    ]
}
