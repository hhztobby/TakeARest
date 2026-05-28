import Foundation
import Observation

@MainActor
@Observable
class DoNotDisturbManager {
    var isDNDActive: Bool = false
    var remainingSeconds: TimeInterval = 0
    var dndEndTime: Date?

    private var timer: Timer?

    // 预设免打扰时长选项
    static let durationOptions: [(String, TimeInterval)] = [
        ("1 小时", 3600),
        ("2 小时", 7200),
        ("3 小时", 10800),
        ("直到手动关闭", 0),
    ]

    func startDND(duration: TimeInterval) {
        isDNDActive = true

        if duration > 0 {
            remainingSeconds = duration
            dndEndTime = Date().addingTimeInterval(duration)
            startCountdown()
        } else {
            // 手动关闭模式
            remainingSeconds = 0
            dndEndTime = nil
        }
    }

    func stopDND() {
        timer?.invalidate()
        timer = nil
        isDNDActive = false
        remainingSeconds = 0
        dndEndTime = nil
    }

    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.remainingSeconds -= 1
                if self.remainingSeconds <= 0 {
                    self.stopDND()
                }
            }
        }
    }

    var formattedRemainingTime: String {
        guard remainingSeconds > 0 else { return "手动关闭" }
        let hours = Int(remainingSeconds) / 3600
        let minutes = (Int(remainingSeconds) % 3600) / 60
        let seconds = Int(remainingSeconds) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
