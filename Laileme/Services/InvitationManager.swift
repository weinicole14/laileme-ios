import Foundation

class InvitationManager {
    static let baseURL = "http://47.123.5.171:8080"

    /// 获取我的邀请码
    static func getMyInviteCode(token: String) async -> String? {
        guard let url = URL(string: "\(baseURL)/api/invite/my-code") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let resultData = json["data"] as? [String: Any] else {
            return nil
        }
        return resultData["inviteCode"] as? String
    }

    /// 获取邀请统计
    static func getInviteStats(token: String) async -> [String: Any]? {
        guard let url = URL(string: "\(baseURL)/api/invite/stats") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let resultData = json["data"] as? [String: Any] else {
            return nil
        }
        return resultData
    }
}
