import SwiftUI

struct SettingsView: View {
    var settings: AppSettings
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TimerSettingsView(settings: settings)
                .tabItem {
                    Label("提醒设置", systemImage: "timer")
                }
                .tag(0)

            MessageSettingsView(settings: settings)
                .tabItem {
                    Label("文案设置", systemImage: "text.quote")
                }
                .tag(1)

            AboutView()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .tag(2)
        }
        .frame(width: 450, height: 350)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 48))
                .foregroundStyle(.brown)
            Text("TakeARest")
                .font(.title)
                .bold()
            Text("定时休息提醒，守护你的健康")
                .foregroundStyle(.secondary)
            Text("版本 1.0.0")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
