import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var isLogin = true
    @State private var username = ""
    @State private var password = ""
    @State private var nickname = ""
    @State private var gender = "female"
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.primaryPink)
                        Text("来了么")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        Text(isLogin ? "欢迎回来" : "创建账号")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 40)

                    // 输入框
                    VStack(spacing: 14) {
                        InputField(icon: "person.fill", placeholder: "用户名", text: $username)

                        if !isLogin {
                            InputField(icon: "face.smiling.fill", placeholder: "昵称", text: $nickname)

                            // 性别选择
                            HStack(spacing: 12) {
                                GenderButton(title: "女生", icon: "♀", isSelected: gender == "female") {
                                    gender = "female"
                                }
                                GenderButton(title: "男生", icon: "♂", isSelected: gender == "male") {
                                    gender = "male"
                                }
                            }
                        }

                        InputField(icon: "lock.fill", placeholder: "密码", text: $password, isSecure: true)

                        if !isLogin {
                            InputField(icon: "ticket.fill", placeholder: "邀请码(选填)", text: $inviteCode)
                        }
                    }
                    .padding(.horizontal, 24)

                    // 错误提示
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.periodRed)
                    }

                    // 登录/注册按钮
                    Button(action: submit) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isLogin ? "登录" : "注册")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(AppColors.primaryPink)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)

                    // 切换登录/注册
                    Button(action: { isLogin.toggle(); errorMessage = "" }) {
                        Text(isLogin ? "没有账号？去注册" : "已有账号？去登录")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryPink)
                    }
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "请填写用户名和密码"
            return
        }
        if !isLogin && nickname.isEmpty {
            errorMessage = "请填写昵称"
            return
        }
        isLoading = true
        errorMessage = ""

        Task {
            let result: AuthResult
            if isLogin {
                result = await authManager.login(username: username, password: password)
            } else {
                result = await authManager.register(username: username, password: password, nickname: nickname, gender: gender, inviteCode: inviteCode)
            }

            await MainActor.run {
                isLoading = false
                if result.success {
                    dismiss()
                } else {
                    errorMessage = result.message
                }
            }
        }
    }
}

// MARK: - 输入框组件
struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.textHint)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.textHint.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - 性别按钮
struct GenderButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                Text(title)
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(isSelected ? AppColors.primaryPink.opacity(0.1) : Color.white)
            .foregroundColor(isSelected ? AppColors.primaryPink : AppColors.textSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primaryPink : AppColors.textHint.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
