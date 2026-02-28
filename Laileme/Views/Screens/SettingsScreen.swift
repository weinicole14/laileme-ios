import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 主题选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("主题颜色")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(0..<themeManager.themes.count, id: \.self) { i in
                                let theme = themeManager.themes[i]
                                Button(action: { themeManager.currentThemeIndex = i }) {
                                    VStack(spacing: 6) {
                                        Circle()
                                            .fill(theme.primary)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                themeManager.currentThemeIndex == i ?
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14, weight: .bold))
                                                : nil
                                            )
                                        Text(theme.name)
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)

                    // 关于
                    VStack(alignment: .leading, spacing: 8) {
                        Text("关于")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("来了么 v1.0.0")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                        Text("联系方式：support@weinicole.cn")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textHint)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(16)
            }
            .background(AppColors.background)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
