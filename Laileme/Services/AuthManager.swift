import SwiftUI
import Combine

struct UserInfo: Codable, Equatable {
    var uid: String
    var username: String
    var nickname: String
    var gender: String
    var avatarUrl: String

    init(uid: String = "", username: String = "", nickname: String = "",
         gender: String = "female", avatarUrl: String = "") {
        self.uid = uid
        self.username = username
        self.nickname = nickname
        self.gender = gender
        self.avatarUrl = avatarUrl
    }
}

struct AuthResult {
    var success: Bool
    var message: String
    var user: UserInfo?
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    static let baseURL = "http://47.123.5.171:8080"

    @Published var currentUser: UserInfo?
    @Published var isLoggedIn: Bool = false

    var token: String {
        get { UserDefaults.standard.string(forKey: "auth_token") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "auth_token") }
    }

    private init() {
        loadSavedUser()
    }

    private func loadSavedUser() {
        let prefs = UserDefaults.standard
        guard let uid = prefs.string(forKey: "user_uid"), !uid.isEmpty else { return }
        currentUser = UserInfo(
            uid: uid,
            username: prefs.string(forKey: "username") ?? "",
            nickname: prefs.string(forKey: "nickname") ?? "",
            gender: prefs.string(forKey: "gender") ?? "female",
            avatarUrl: prefs.string(forKey: "avatar_url") ?? ""
        )
        isLoggedIn = true
    }

    func login(username: String, password: String) async -> AuthResult {
        guard let url = URL(string: "\(Self.baseURL)/api/auth/login") else {
            return AuthResult(success: false, message: "URL错误")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let code = json["code"] as? Int else {
                return AuthResult(success: false, message: "解析失败")
            }
            if code == 200, let dataObj = json["data"] as? [String: Any] {
                let token = dataObj["token"] as? String ?? ""
                let user = parseUser(from: dataObj)
                self.token = token
                saveUser(user)
                await MainActor.run {
                    self.currentUser = user
                    self.isLoggedIn = true
                }
                return AuthResult(success: true, message: "登录成功", user: user)
            } else {
                return AuthResult(success: false, message: json["message"] as? String ?? "登录失败")
            }
        } catch {
            return AuthResult(success: false, message: "网络错误: \(error.localizedDescription)")
        }
    }

    func register(username: String, password: String, nickname: String, gender: String, inviteCode: String = "") async -> AuthResult {
        guard let url = URL(string: "\(Self.baseURL)/api/auth/register") else {
            return AuthResult(success: false, message: "URL错误")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: String] = [
            "username": username, "password": password,
            "nickname": nickname, "gender": gender
        ]
        if !inviteCode.isEmpty { body["inviteCode"] = inviteCode }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let code = json["code"] as? Int else {
                return AuthResult(success: false, message: "解析失败")
            }
            if code == 200, let dataObj = json["data"] as? [String: Any] {
                let token = dataObj["token"] as? String ?? ""
                let user = parseUser(from: dataObj)
                self.token = token
                saveUser(user)
                await MainActor.run {
                    self.currentUser = user
                    self.isLoggedIn = true
                }
                return AuthResult(success: true, message: "注册成功", user: user)
            } else {
                return AuthResult(success: false, message: json["message"] as? String ?? "注册失败")
            }
        } catch {
            return AuthResult(success: false, message: "网络错误: \(error.localizedDescription)")
        }
    }

    func logout() {
        token = ""
        UserDefaults.standard.removeObject(forKey: "user_uid")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "nickname")
        UserDefaults.standard.removeObject(forKey: "gender")
        UserDefaults.standard.removeObject(forKey: "avatar_url")
        currentUser = nil
        isLoggedIn = false
    }

    private func parseUser(from data: [String: Any]) -> UserInfo {
        UserInfo(
            uid: data["uid"] as? String ?? "",
            username: data["username"] as? String ?? "",
            nickname: data["nickname"] as? String ?? "",
            gender: data["gender"] as? String ?? "female",
            avatarUrl: data["avatarUrl"] as? String ?? ""
        )
    }

    private func saveUser(_ user: UserInfo) {
        let prefs = UserDefaults.standard
        prefs.set(user.uid, forKey: "user_uid")
        prefs.set(user.username, forKey: "username")
        prefs.set(user.nickname, forKey: "nickname")
        prefs.set(user.gender, forKey: "gender")
        prefs.set(user.avatarUrl, forKey: "avatar_url")
    }
}
