import SwiftUI

struct StatisticsView: View {
    var statisticsManager: StatisticsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日统计")
                .font(.title2)
                .bold()

            HStack(spacing: 24) {
                StatCard(
                    icon: "clock.fill",
                    title: "工作时长",
                    value: statisticsManager.formattedTodayWorkTime,
                    color: .blue
                )

                StatCard(
                    icon: "cup.and.saucer.fill",
                    title: "休息次数",
                    value: "\(statisticsManager.todayRestCount) 次",
                    color: .green
                )
            }

            Divider()

            Text("本周趋势")
                .font(.headline)

            // 简易柱状图
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(statisticsManager.weeklyData.enumerated()), id: \.offset) { _, data in
                    let (_, duration) = data
                    let maxHeight: CGFloat = 100
                    let maxDuration = statisticsManager.weeklyData.map(\.1).max() ?? 1
                    let barHeight = maxDuration > 0 ? (duration / maxDuration) * maxHeight : 0

                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(duration > 0 ? .blue : .gray.opacity(0.2))
                            .frame(height: max(barHeight, 4))

                        Text(dayLabel(for: data.0))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}
