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
    private let settings: AppSettings
    private let notificationManager = NotificationManager.shared

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
        startWorking()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        state = .idle
        remainingTime = 0
    }

    func triggerNow() {
        sendReminder()
    }

    // MARK: - 状态转换

    private func startWorking() {
        state = .working
        remainingTime = settings.remindInterval
        startCountdown()
    }

    private func sendReminder() {
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
