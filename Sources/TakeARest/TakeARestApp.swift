import SwiftUI

@main
struct TakeARestApp: App {
    @State private var settings = AppSettings()
    @State private var timerManager: TimerManager

    init() {
        let settings = AppSettings()
        let timerManager = TimerManager(settings: settings)
        _settings = State(initialValue: settings)
        _timerManager = State(initialValue: timerManager)

        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        MenuBarExtra("TakeARest", systemImage: "cup.and.saucer.fill") {
            MenuBarView(timerManager: timerManager)
        }
    }
}
