import SwiftUI

@main
struct TakeARestApp: App {
    @State private var settings = AppSettings()
    @State private var timerManager: TimerManager
    @State private var dndManager = DoNotDisturbManager()
    @State private var statisticsManager = StatisticsManager()
    @State private var showSettings = false

    init() {
        let settings = AppSettings()
        let timerManager = TimerManager(settings: settings)
        _settings = State(initialValue: settings)
        _timerManager = State(initialValue: timerManager)

        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        MenuBarExtra("TakeARest", systemImage: "cup.and.saucer.fill") {
            MenuBarView(
                timerManager: timerManager,
                dndManager: dndManager,
                showSettings: $showSettings
            )
            .onAppear {
                timerManager.dndManager = dndManager
                timerManager.statisticsManager = statisticsManager
            }
        }

        Window("TakeARest 设置", id: "settings") {
            SettingsView(settings: settings, statisticsManager: statisticsManager)
        }
        .defaultSize(width: 480, height: 380)
    }
}
