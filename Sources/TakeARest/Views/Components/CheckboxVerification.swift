import SwiftUI

struct CheckboxVerification: View {
    @Binding var isPassed: Bool
    @State private var targetNumber: Int
    @State private var inputText = ""

    init(isPassed: Binding<Bool>) {
        self._isPassed = isPassed
        self._targetNumber = State(initialValue: Int.random(in: 10...99))
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("请输入下方数字")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(targetNumber)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)

            TextField("输入数字", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .onChange(of: inputText) { _, newValue in
                    if Int(newValue) == targetNumber {
                        isPassed = true
                    }
                }
        }
    }
}
