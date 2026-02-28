import SwiftUI
import SwiftData

struct StatsScreen: View {
    @Query(sort: \PeriodRecord.startDate, order: .reverse) private var records: [PeriodRecord]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("数据统计")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 20)

                // 周期统计卡片
                StatCard(title: "平均周期", value: "\(avgCycle)天", icon: "calendar.circle.fill", color: AppColors.primaryPink)
                StatCard(title: "平均经期", value: "\(avgPeriod)天", icon: "drop.fill", color: AppColors.periodRed)
                StatCard(title: "总记录数", value: "\(records.count)次", icon: "list.bullet", color: AppColors.accentTeal)

                // 最近记录
                VStack(alignment: .leading, spacing: 8) {
                    Text("最近记录")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    ForEach(records.prefix(5)) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatDate(record.startDate))
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("周期 \(record.cycleLength)天 · 经期 \(record.periodLength)天")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            if record.endDate != nil {
                                Text("已结束")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.accentTeal)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.accentTeal.opacity(0.1))
                                    .cornerRadius(8)
                            } else {
                                Text("进行中")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.periodRed)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.periodRed.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "FAFAFA"))
                        .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
        }
        .background(AppColors.background)
    }

    private var avgCycle: Int {
        let completed = records.filter { $0.endDate != nil }
        guard !completed.isEmpty else { return 28 }
        return completed.map { $0.cycleLength }.reduce(0, +) / completed.count
    }

    private var avgPeriod: Int {
        let completed = records.filter { $0.endDate != nil }
        guard !completed.isEmpty else { return 5 }
        return completed.map { $0.periodLength }.reduce(0, +) / completed.count
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        return f.string(from: date)
    }
}

struct StatCard: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .cornerRadius(14)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(AppColors.textPrimary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}
