import SwiftUI

struct SliderVerification: View {
    @Binding var isPassed: Bool
    @State private var sliderValue: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("将滑块拖到最右边")
                .font(.caption)
                .foregroundStyle(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景轨道
                    Capsule()
                        .fill(isPassed ? .green.opacity(0.3) : .gray.opacity(0.2))
                        .frame(height: 36)

                    // 滑块
                    Circle()
                        .fill(isPassed ? .green : .blue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.white)
                        )
                        .offset(x: sliderValue * (geometry.size.width - 32))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isPassed {
                                        let newValue = value.translation.width / (geometry.size.width - 32)
                                        sliderValue = min(max(0, newValue + sliderValue), 1)
                                        if sliderValue > 0.95 {
                                            sliderValue = 1
                                            isPassed = true
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(height: 36)
        }
    }
}
