import Foundation

struct PartnerData {
    let nickname: String
    let periodRecords: [[String: Any]]
    let sleepRecords: [[String: Any]]
}

class PartnerManager {
    static let baseURL = "http://47.123.5.171:8080"

    /// 获取伴侣数据
    static func getPartnerData(token: String) async -> PartnerData? {
        guard let url = URL(string: "\(baseURL)/api/partner/data") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool, success,
              let resultData = json["data"] as? [String: Any] else {
            return nil
        }

        return PartnerData(
            nickname: resultData["nickname"] as? String ?? "",
            periodRecords: resultData["periodRecords"] as? [[String: Any]] ?? [],
            sleepRecords: resultData["sleepRecords"] as? [[String: Any]] ?? []
        )
    }

    /// 绑定伴侣
    static func bindPartner(token: String, partnerUid: String) async -> (Bool, String) {
        guard let url = URL(string: "\(baseURL)/api/partner/bind") else {
            return (false, "URL错误")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["partnerUid": partnerUid])

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (false, "网络错误")
        }

        let success = json["success"] as? Bool ?? false
        let message = json["message"] as? String ?? (success ? "绑定成功" : "绑定失败")
        return (success, message)
    }

    /// 解除绑定
    static func unbindPartner(token: String) async -> (Bool, String) {
        guard let url = URL(string: "\(baseURL)/api/partner/unbind") else {
            return (false, "URL错误")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (false, "网络错误")
        }

        let success = json["success"] as? Bool ?? false
        let message = json["message"] as? String ?? (success ? "解绑成功" : "解绑失败")
        return (success, message)
    }

    /// 检查伴侣数据更新
    static func checkPartnerUpdate(token: String) async -> (Bool, String) {
        guard let url = URL(string: "\(baseURL)/api/partner/check-update") else {
            return (false, "")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let resultData = json["data"] as? [String: Any] else {
            return (false, "")
        }

        let hasUpdate = resultData["hasUpdate"] as? Bool ?? false
        let fromNickname = resultData["fromNickname"] as? String ?? ""
        return (hasUpdate, fromNickname)
    }

    /// 获取伴侣信息
    static func getPartnerInfo(token: String) async -> [String: Any]? {
        guard let url = URL(string: "\(baseURL)/api/partner/info") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool, success,
              let resultData = json["data"] as? [String: Any] else {
            return nil
        }

        return resultData
    }
}
