import Foundation

struct WorkSession: Codable, Identifiable {
    let id: UUID
    let date: Date       // 日期（只取年月日）
    var totalWorkTime: TimeInterval
    var restCount: Int

    init(date: Date) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.totalWorkTime = 0
        self.restCount = 0
    }

    mutating func addRest(workDuration: TimeInterval) {
        totalWorkTime += workDuration
        restCount += 1
    }
}
