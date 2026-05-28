import SwiftUI

struct DNDConfirmView: View {
    var onComplete: (TimeInterval) -> Void
    var onCancel: () -> Void

    @State private var selectedDuration: TimeInterval = 3600
    @State private var verificationSteps: [VerificationStep] = []
    @State private var currentStepIndex = 0
    @State private var stepPassed: [Bool] = []
    @State private var showVerification = false

    enum VerificationStep: CaseIterable {
        case slider
        case checkbox
        case countdown
    }

    var body: some View {
        VStack(spacing: 16) {
            if !showVerification {
                durationSelectionView
            } else {
                verificationView
            }
        }
        .padding(24)
        .frame(width: 350)
    }

    // MARK: - 时长选择

    private var durationSelectionView: some View {
        VStack(spacing: 16) {
            Text("免打扰模式")
                .font(.title2)
                .bold()

            Text("选择免打扰时长")
                .foregroundStyle(.secondary)

            ForEach(DoNotDisturbManager.durationOptions, id: \.1) { option in
                Button {
                    selectedDuration = option.1
                } label: {
                    HStack {
                        Text(option.0)
                        Spacer()
                        if selectedDuration == option.1 {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedDuration == option.1 ? .blue.opacity(0.1) : .clear)
                    )
                }
                .buttonStyle(.plain)
            }

            Divider()

            HStack {
                Button("取消") {
                    onCancel()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("开启免打扰") {
                    startVerification()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - 验证流程

    private var verificationView: some View {
        VStack(spacing: 16) {
            Text("验证确认")
                .font(.title2)
                .bold()

            Text("完成以下验证以开启免打扰")
                .foregroundStyle(.secondary)

            // 进度指示
            HStack(spacing: 8) {
                ForEach(0..<verificationSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index < currentStepIndex ? .green : index == currentStepIndex ? .blue : .gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }

            // 当前验证步骤
            currentVerificationView

            Divider()

            HStack {
                Button("取消") {
                    onCancel()
                }
                .buttonStyle(.bordered)

                Spacer()

                if isCurrentStepPassed && currentStepIndex < verificationSteps.count - 1 {
                    Button("下一步") {
                        currentStepIndex += 1
                    }
                    .buttonStyle(.borderedProminent)
                } else if isAllPassed {
                    Button("确认开启") {
                        onComplete(selectedDuration)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
    }

    @ViewBuilder
    private var currentVerificationView: some View {
        if currentStepIndex < verificationSteps.count {
            let step = verificationSteps[currentStepIndex]
            let binding = $stepPassed[currentStepIndex]

            switch step {
            case .slider:
                SliderVerification(isPassed: binding)
            case .checkbox:
                CheckboxVerification(isPassed: binding)
            case .countdown:
                CountdownTimer(isPassed: binding)
            }
        }
    }

    private var isCurrentStepPassed: Bool {
        guard currentStepIndex < stepPassed.count else { return false }
        return stepPassed[currentStepIndex]
    }

    private var isAllPassed: Bool {
        stepPassed.allSatisfy { $0 }
    }

    private func startVerification() {
        // 随机选择 2-3 种验证方式
        let allSteps = VerificationStep.allCases
        let count = Int.random(in: 2...min(3, allSteps.count))
        verificationSteps = Array(allSteps.shuffled().prefix(count))
        stepPassed = Array(repeating: false, count: verificationSteps.count)
        currentStepIndex = 0
        showVerification = true
    }
}
