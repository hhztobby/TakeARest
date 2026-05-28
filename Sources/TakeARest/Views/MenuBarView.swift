import SwiftUI

struct MenuBarView: View {
    @Binding var statusText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 8))
                Text(statusText)
                    .font(.headline)
            }
            .padding(.horizontal)

            Divider()

            Button("设置") {
                // TODO: 第三阶段实现
            }

            Divider()

            Button("退出 TakeARest") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 8)
        .frame(width: 200)
    }
}
