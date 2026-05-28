import Foundation
import Observation

@MainActor
@Observable
class StatisticsManager {
    private(set) var todayWorkTime: TimeInterval = 0
    private(set) var todayRestCount: Int = 0
    private(set) var weeklyData: [(Date, TimeInterval)] = []

    private var sessions: [WorkSession] = []
    private let storageKey = "workSessions"
    private var workStartTime: Date?

    init() {
        loadSessions()
        updateTodayStats()
        updateWeeklyData()
    }

    // 开始工作计时
    func startWork() {
        workStartTime = Date()
    }

    // 记录休息
    func recordRest() {
        guard let startTime = workStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)

        let today = Calendar.current.startOfDay(for: Date())
        if let index = sessions.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            sessions[index].addRest(workDuration: duration)
        } else {
            var session = WorkSession(date: today)
            session.addRest(workDuration: duration)
            sessions.append(session)
        }

        workStartTime = Date()  // 重新开始计时
        saveSessions()
        updateTodayStats()
        updateWeeklyData()
    }

    // 更新今日统计
    private func updateTodayStats() {
        let today = Calendar.current.startOfDay(for: Date())
        if let session = sessions.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            todayWorkTime = session.totalWorkTime
            todayRestCount = session.restCount
        } else {
            todayWorkTime = 0
            todayRestCount = 0
        }
    }

    // 更新本周数据
    private func updateWeeklyData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!

        weeklyData = (0...6).compactMap { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekAgo)!
            let session = sessions.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
            return (date, session?.totalWorkTime ?? 0)
        }
    }

    // 持久化
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([WorkSession].self, from: data) {
            sessions = decoded
        }
    }

    // 格式化
    var formattedTodayWorkTime: String {
        todayWorkTime.formattedDuration
    }
}
