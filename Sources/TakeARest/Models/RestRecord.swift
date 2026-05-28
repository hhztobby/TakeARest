import Foundation

struct RestRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let workDuration: TimeInterval  // 工作了多久才休息

    init(date: Date, workDuration: TimeInterval) {
        self.id = UUID()
        self.date = date
        self.workDuration = workDuration
    }
}
