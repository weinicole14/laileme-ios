import SwiftUI
import SwiftData

struct HomeScreen: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodRecord.startDate, order: .reverse) private var records: [PeriodRecord]

    @State private var announcement: String = ""
    @State private var careMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 顶部标题
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("来了么")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        Text(greetingText)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    // 头像
                    Circle()
                        .fill(AppColors.primaryPink.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(AppColors.primaryPink)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)

                // 公告栏
                if !announcement.isEmpty {
                    HStack {
                        Image(systemName: "megaphone.fill")
                            .foregroundColor(AppColors.accentOrange)
                            .font(.system(size: 12))
                        Text(announcement)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(12)
                    .background(AppColors.accentOrange.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }

                // 经期状态卡片
                PeriodStatusCard(records: records)
                    .padding(.horizontal, 16)

                // 伴侣关怀消息
                if !careMessage.isEmpty {
                    CareMessageCard(message: careMessage)
                        .padding(.horizontal, 16)
                }

                // 健康提示
                HealthTipsCard()
                    .padding(.horizontal, 16)

                Spacer(minLength: 80)
            }
        }
        .background(AppColors.background)
        .onAppear { loadData() }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = authManager.currentUser?.nickname ?? "宝贝"
        switch hour {
        case 6..<12: return "早上好，\(name) ☀️"
        case 12..<14: return "中午好，\(name) 🌤"
        case 14..<18: return "下午好，\(name) 🌸"
        case 18..<22: return "晚上好，\(name) 🌙"
        default: return "夜深了，\(name) 💤"
        }
    }

    private func loadData() {
        // 加载公告
        Task {
            guard let url = URL(string: "\(AuthManager.baseURL)/api/announcements") else { return }
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let code = json["code"] as? Int, code == 200,
               let dataObj = json["data"] as? [[String: Any]],
               let first = dataObj.first,
               let content = first["content"] as? String {
                await MainActor.run { announcement = content }
            }
        }
    }
}

// MARK: - 经期状态卡片
struct PeriodStatusCard: View {
    let records: [PeriodRecord]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(statusTitle)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    Text(statusValue)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.periodRed)
                }
                Spacer()
                // 圆环进度
                ZStack {
                    Circle()
                        .stroke(AppColors.periodRed.opacity(0.15), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppColors.periodRed, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 60, height: 60)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }

    private var statusTitle: String {
        guard let latest = records.first else { return "经期" }
        if latest.endDate == nil { return "经期中" }
        return "距下次经期"
    }

    private var statusValue: String {
        guard let latest = records.first else { return "未记录" }
        let now = Date()
        if latest.endDate == nil {
            let days = Calendar.current.dateComponents([.day], from: latest.startDate, to: now).day ?? 0
            let left = max(latest.periodLength - days - 1, 0)
            return "\(left)天后结束"
        }
        let days = Calendar.current.dateComponents([.day], from: latest.startDate, to: now).day ?? 0
        let cyclesPassed = days > 0 ? days / latest.cycleLength : 0
        let nextStart = Calendar.current.date(byAdding: .day, value: (cyclesPassed + 1) * latest.cycleLength, to: latest.startDate) ?? now
        let until = max(Calendar.current.dateComponents([.day], from: now, to: nextStart).day ?? 0, 0)
        return "\(until)天"
    }

    private var progress: CGFloat {
        guard let latest = records.first, latest.endDate != nil else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: latest.startDate, to: Date()).day ?? 0
        let dayInCycle = days % latest.cycleLength
        return CGFloat(dayInCycle) / CGFloat(latest.cycleLength)
    }
}

// MARK: - 关怀消息卡片
struct CareMessageCard: View {
    let message: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .foregroundColor(AppColors.periodRed)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding(16)
        .background(AppColors.periodRed.opacity(0.06))
        .cornerRadius(16)
    }
}

// MARK: - 健康提示
struct HealthTipsCard: View {
    private let tips = [
        "💧 记得多喝温水，保持身体水分充足",
        "🧘 适当运动可以缓解经期不适",
        "😴 保持充足睡眠，早睡早起",
        "🍎 多吃富含铁的食物",
        "🌸 保持心情愉快，适当放松"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("健康小贴士")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            Text(tips.randomElement() ?? tips[0])
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.accentTeal.opacity(0.08))
        .cornerRadius(16)
    }
}
