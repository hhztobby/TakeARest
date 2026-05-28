import Foundation
import Observation

enum AppState: String {
    case idle = "空闲"
    case working = "工作中"
    case reminding = "等待休息"
    case resting = "休息中"
    case snoozed = "稍后提醒"
}

@MainActor
@Observable
class TimerManager {
    var state: AppState = .idle
    var remainingTime: TimeInterval = 0
    var isRunning: Bool = false

    private var timer: Timer?
    private var activityCheckTimer: Timer?
    private let settings: AppSettings
    private let notificationManager = NotificationManager.shared
    let activityMonitor = ActivityMonitor()
    let screenDetector = ScreenChangeDetector()
    var dndManager: DoNotDisturbManager?

    init(settings: AppSettings) {
        self.settings = settings
        setupNotificationCallbacks()
    }

    private func setupNotificationCallbacks() {
        notificationManager.onConfirm = { [weak self] in
            self?.confirmRest()
        }
        notificationManager.onSnooze = { [weak self] in
            self?.snooze()
        }
    }

    // MARK: - 公开方法

    func start() {
        guard !isRunning else { return }
        isRunning = true
        activityMonitor.start()
        screenDetector.start()
        startWorking()
        startActivityCheck()
    }

    func stop() {
        timer?.invalidate()
        activityCheckTimer?.invalidate()
        timer = nil
        activityCheckTimer = nil
        isRunning = false
        state = .idle
        remainingTime = 0
        screenDetector.stop()
    }

    func triggerNow() {
        sendReminder()
    }

    // MARK: - 活动检测

    private func startActivityCheck() {
        activityCheckTimer?.invalidate()
        activityCheckTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkUserActivity()
            }
        }
    }

    private func checkUserActivity() {
        guard isRunning, state == .working || state == .reminding else { return }

        let isActive = activityMonitor.checkActivity(threshold: settings.restThreshold)

        // 如果用户没有键鼠活动，但屏幕在变化（如看视频），仍视为活动中
        if !isActive && screenDetector.isScreenChanging {
            return
        }

        // 用户无活动且屏幕无变化 = 休息状态
        if !isActive {
            timer?.invalidate()
            state = .resting
            remainingTime = 60
            startCountdown { [weak self] in
                self?.startWorking()
            }
        }
    }

    // MARK: - 状态转换

    private func startWorking() {
        state = .working
        remainingTime = settings.remindInterval
        startCountdown()
    }

    private func sendReminder() {
        // 免打扰期间不发送提醒
        if dndManager?.isDNDActive == true {
            // 继续正常计时，但不发送通知
            state = .working
            remainingTime = settings.remindInterval
            startCountdown()
            return
        }
        timer?.invalidate()
        state = .reminding
        remainingTime = settings.repeatInterval
        notificationManager.sendReminder(message: settings.randomMessage)
        startRepeatCountdown()
    }

    private func confirmRest() {
        timer?.invalidate()
        state = .resting
        remainingTime = 60
        startCountdown { [weak self] in
            self?.startWorking()
        }
    }

    private func snooze() {
        timer?.invalidate()
        state = .snoozed
        remainingTime = settings.snoozeDelay
        startCountdown { [weak self] in
            self?.startWorking()
        }
    }

    // MARK: - 倒计时

    private func startCountdown(onComplete: (@MainActor () -> Void)? = nil) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.timer?.invalidate()
                    onComplete?()
                }
            }
        }
    }

    private func startRepeatCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.sendReminder()
                }
            }
        }
    }

    // MARK: - 格式化

    var formattedRemainingTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
