import SwiftUI

struct DiscoverScreen: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("发现")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 50)

                // 功能卡片
                VStack(spacing: 12) {
                    DiscoverCard(icon: "book.fill", title: "经期知识", subtitle: "了解更多关于经期的健康知识", color: AppColors.periodRed)
                    DiscoverCard(icon: "heart.text.square.fill", title: "健康日记", subtitle: "记录每天的身体状态和心情", color: AppColors.accentTeal)
                    DiscoverCard(icon: "moon.fill", title: "睡眠记录", subtitle: "追踪你的睡眠质量", color: AppColors.accentBlue)
                    DiscoverCard(icon: "chart.bar.fill", title: "统计分析", subtitle: "查看你的经期数据统计", color: AppColors.accentOrange)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 80)
            }
        }
        .background(AppColors.background)
    }
}

struct DiscoverCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textHint)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
    }
}
