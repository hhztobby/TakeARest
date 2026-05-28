import SwiftUI

struct TimerSettingsView: View {
    var settings: AppSettings

    @State private var remindMinutes: Double
    @State private var repeatMinutes: Double
    @State private var snoozeMinutes: Double
    @State private var restThresholdSeconds: Double

    init(settings: AppSettings) {
        self.settings = settings
        _remindMinutes = State(initialValue: settings.remindInterval / 60)
        _repeatMinutes = State(initialValue: settings.repeatInterval / 60)
        _snoozeMinutes = State(initialValue: settings.snoozeDelay / 60)
        _restThresholdSeconds = State(initialValue: settings.restThreshold)
    }

    var body: some View {
        Form {
            Section("定时提醒") {
                HStack {
                    Text("提醒间隔")
                    Spacer()
                    Text("\(Int(remindMinutes)) 分钟")
                        .foregroundStyle(.secondary)
                        .frame(width: 80)
                }
                Slider(value: $remindMinutes, in: 5...120, step: 5) {
                    Text("提醒间隔")
                } onEditingChanged: { _ in
                    settings.remindInterval = remindMinutes * 60
                }

                HStack {
                    Text("未休息重复提醒")
                    Spacer()
                    Text("\(Int(repeatMinutes)) 分钟")
                        .foregroundStyle(.secondary)
                        .frame(width: 80)
                }
                Slider(value: $repeatMinutes, in: 1...10, step: 1) {
                    Text("重复间隔")
                } onEditingChanged: { _ in
                    settings.repeatInterval = repeatMinutes * 60
                }

                HStack {
                    Text("稍后提醒延迟")
                    Spacer()
                    Text("\(Int(snoozeMinutes)) 分钟")
                        .foregroundStyle(.secondary)
                        .frame(width: 80)
                }
                Slider(value: $snoozeMinutes, in: 5...30, step: 5) {
                    Text("稍后延迟")
                } onEditingChanged: { _ in
                    settings.snoozeDelay = snoozeMinutes * 60
                }
            }

            Section("休息判定") {
                HStack {
                    Text("无活动判定阈值")
                    Spacer()
                    Text("\(Int(restThresholdSeconds)) 秒")
                        .foregroundStyle(.secondary)
                        .frame(width: 80)
                }
                Slider(value: $restThresholdSeconds, in: 10...120, step: 10) {
                    Text("阈值")
                } onEditingChanged: { _ in
                    settings.restThreshold = restThresholdSeconds
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
