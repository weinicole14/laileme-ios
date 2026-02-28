import Foundation
import SwiftData

/// 数据同步管理器 - 所有登录用户自动同步数据到服务器
class SyncManager {
    static let shared = SyncManager()
    private let baseURL = "http://47.123.5.171:8080"

    private var syncTimer: Timer?
    private var token: String { AuthManager.shared.token }

    private init() {}

    // MARK: - Auto Sync
    func startAutoSync() {
        stopAutoSync()
        guard !token.isEmpty else { return }

        // 立即同步一次
        Task { await performSync() }

        // 每5分钟同步一次
        DispatchQueue.main.async {
            self.syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                Task { await self?.performSync() }
            }
        }
    }

    func stopAutoSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }

    func triggerImmediateSync() {
        guard !token.isEmpty else { return }
        Task { await performSync() }
    }

    // MARK: - Upload
    func performSync() async {
        guard !token.isEmpty else { return }

        // 心跳
        await sendHeartbeat()

        // 构建同步数据（需要从SwiftData获取）
        // 简化版：通过Notification让App层提供数据
        NotificationCenter.default.post(name: .syncRequested, object: nil)
    }

    /// 上传数据到服务器
    func uploadData(_ json: [String: Any]) async throws {
        guard let url = URL(string: "\(baseURL)/api/sync/upload") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SyncError.serverError
        }
        if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let success = result["success"] as? Bool, success {
            let lastSync = (result["data"] as? [String: Any])?["lastSync"] as? String ?? ""
            UserDefaults.standard.set(lastSync, forKey: "last_sync_time")
            print("[SyncManager] Upload success: \(lastSync)")
        }
    }

    // MARK: - Download & Restore
    func downloadAndRestore() async throws -> String {
        guard !token.isEmpty else { throw SyncError.notLoggedIn }
        guard let url = URL(string: "\(baseURL)/api/sync/download") else { throw SyncError.serverError }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SyncError.serverError
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool, success,
              let resultData = json["data"] as? [String: Any] else {
            throw SyncError.parseFailed
        }

        // 恢复个人档案
        if let profile = resultData["profile"] as? [String: Any] {
            let defaults = UserDefaults.standard
            defaults.set(profile["nickname"] as? String ?? "", forKey: "profile_nickname")
            defaults.set(profile["birth_year"] as? String ?? "", forKey: "profile_birth_year")
            defaults.set(profile["birth_month"] as? String ?? "", forKey: "profile_birth_month")
            defaults.set(profile["birth_day"] as? String ?? "", forKey: "profile_birth_day")
            defaults.set(profile["height"] as? String ?? "", forKey: "profile_height")
            defaults.set(profile["weight"] as? String ?? "", forKey: "profile_weight")
            defaults.set(profile["blood_type"] as? String ?? "", forKey: "profile_blood_type")
        }

        // 恢复经期设置
        if let settings = resultData["settings"] as? [String: Any] {
            let defaults = UserDefaults.standard
            defaults.set(settings["has_setup"] as? Bool ?? false, forKey: "has_setup")
            defaults.set(settings["tracking_mode"] as? String ?? "auto", forKey: "tracking_mode")
            defaults.set(settings["cycle_length"] as? Int ?? 28, forKey: "cycle_length")
            defaults.set(settings["period_length"] as? Int ?? 5, forKey: "period_length")
        }

        // 恢复药物提醒
        if let discover = resultData["discover"] as? [String: Any] {
            UserDefaults.standard.set(discover["medications"] as? String ?? "", forKey: "medications")
            UserDefaults.standard.set(discover["water_goal"] as? Int ?? 8, forKey: "water_goal")
        }

        // 通知App层恢复SwiftData记录
        NotificationCenter.default.post(name: .restoreDataReceived, object: resultData)

        var total = 0
        total += (resultData["periodRecords"] as? [[String: Any]])?.count ?? 0
        total += (resultData["diaryEntries"] as? [[String: Any]])?.count ?? 0
        total += (resultData["sleepRecords"] as? [[String: Any]])?.count ?? 0
        total += (resultData["secretRecords"] as? [[String: Any]])?.count ?? 0

        return "数据恢复成功，共 \(total) 条记录"
    }

    // MARK: - Heartbeat
    private func sendHeartbeat() async {
        guard let url = URL(string: "\(baseURL)/api/heartbeat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        _ = try? await URLSession.shared.data(for: request)
    }

    func getLastSyncTime() -> String? {
        UserDefaults.standard.string(forKey: "last_sync_time")
    }
}

enum SyncError: Error, LocalizedError {
    case notLoggedIn, serverError, parseFailed

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "未登录"
        case .serverError: return "服务器错误"
        case .parseFailed: return "数据解析失败"
        }
    }
}

extension Notification.Name {
    static let syncRequested = Notification.Name("syncRequested")
    static let restoreDataReceived = Notification.Name("restoreDataReceived")
    static let partnerDataUpdated = Notification.Name("partnerDataUpdated")
}
