import SwiftUI

struct MenuBarView: View {
    var timerManager: TimerManager
    @Binding var showSettings: Bool
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 状态显示
            HStack {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .font(.system(size: 8))
                Text(timerManager.state.rawValue)
                    .font(.headline)
            }
            .padding(.horizontal)

            // 倒计时
            if timerManager.isRunning {
                HStack {
                    Text("剩余时间")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(timerManager.formattedRemainingTime)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal)
            }

            Divider()

            // 开始/停止
            if timerManager.isRunning {
                Button("停止计时") {
                    timerManager.stop()
                }
            } else {
                Button("开始计时") {
                    timerManager.start()
                }
            }

            // 立即提醒（测试用）
            if timerManager.isRunning {
                Button("立即提醒") {
                    timerManager.triggerNow()
                }
            }

            Divider()

            Button("设置") {
                openWindow(id: "settings")
            }

            Divider()

            Button("退出 TakeARest") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 8)
        .frame(width: 220)
    }

    private var statusIcon: String {
        switch timerManager.state {
        case .working: return "circle.fill"
        case .reminding: return "exclamationmark.circle.fill"
        case .resting: return "moon.fill"
        case .snoozed: return "clock.fill"
        case .idle: return "pause.circle.fill"
        }
    }

    private var statusColor: Color {
        switch timerManager.state {
        case .working: return .green
        case .reminding: return .orange
        case .resting: return .blue
        case .snoozed: return .yellow
        case .idle: return .gray
        }
    }
}
