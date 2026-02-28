import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showLogin = false
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 标题
                Text("我的")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 50)

                // 头像区域
                VStack(spacing: 12) {
                    if authManager.isLoggedIn {
                        // 已登录 — 头像
                        Circle()
                            .fill(AppColors.primaryPink.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppColors.primaryPink)
                            )
                        Text(authManager.currentUser?.nickname ?? "用户")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("UID: \(authManager.currentUser?.uid ?? "")")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textHint)
                    } else {
                        // 未登录
                        Circle()
                            .fill(AppColors.textHint.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppColors.textHint)
                            )
                        Button("点击登录") {
                            showLogin = true
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryPink)
                    }
                }
                .padding(.vertical, 20)

                // 功能菜单
                VStack(spacing: 0) {
                    ProfileMenuItem(icon: "person.2.fill", title: "伴侣管理", color: AppColors.periodRed)
                    Divider().padding(.leading, 56)
                    ProfileMenuItem(icon: "paintbrush.fill", title: "主题设置", color: AppColors.accentTeal) {
                        showSettings = true
                    }
                    Divider().padding(.leading, 56)
                    ProfileMenuItem(icon: "bell.fill", title: "通知设置", color: AppColors.accentOrange)
                    Divider().padding(.leading, 56)
                    ProfileMenuItem(icon: "lock.fill", title: "隐私日记", color: Color(hex: "9B59B6"))
                    Divider().padding(.leading, 56)
                    ProfileMenuItem(icon: "questionmark.circle.fill", title: "帮助反馈", color: AppColors.accentBlue)
                }
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 16)

                // 退出登录
                if authManager.isLoggedIn {
                    Button(action: { authManager.logout() }) {
                        Text("退出登录")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.periodRed)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                Spacer(minLength: 80)
            }
        }
        .background(AppColors.background)
        .sheet(isPresented: $showLogin) {
            LoginScreen()
        }
        .sheet(isPresented: $showSettings) {
            SettingsScreen()
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .cornerRadius(8)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textHint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
