import SwiftUI

struct MessageSettingsView: View {
    var settings: AppSettings
    @State private var newMessage = ""
    @State private var messages: [String]

    init(settings: AppSettings) {
        self.settings = settings
        _messages = State(initialValue: settings.customMessages)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 添加新文案
            HStack {
                TextField("输入新的提醒文案", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                Button("添加") {
                    let trimmed = newMessage.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    messages.append(trimmed)
                    settings.customMessages = messages
                    newMessage = ""
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()

            Divider()

            // 文案列表
            List {
                ForEach(messages, id: \.self) { message in
                    HStack {
                        Text(message)
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    // 保留至少一条文案
                    if messages.count > 1 {
                        messages.remove(atOffsets: indexSet)
                        settings.customMessages = messages
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
