import SwiftUI

struct CountdownTimer: View {
    @Binding var isPassed: Bool
    @State private var secondsRemaining: Int
    @State private var timer: Timer?

    init(isPassed: Binding<Bool>) {
        self._isPassed = isPassed
        self._secondsRemaining = State(initialValue: Int.random(in: 3...8))
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("请等待倒计时结束")
                .font(.caption)
                .foregroundStyle(.secondary)

            if secondsRemaining > 0 {
                Text("\(secondsRemaining)")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)
            } else {
                Button("确认") {
                    isPassed = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Task { @MainActor in
                    if secondsRemaining > 0 {
                        secondsRemaining -= 1
                    } else {
                        timer?.invalidate()
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}
