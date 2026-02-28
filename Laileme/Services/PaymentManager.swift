import Foundation
import StoreKit

class PaymentManager: ObservableObject {
    static let shared = PaymentManager()

    @Published var isVip: Bool = false
    @Published var vipExpiry: String = ""

    private let baseURL = "http://47.123.5.171:8080"

    private init() {
        checkVipStatus()
    }

    func checkVipStatus() {
        let token = AuthManager.shared.token
        guard !token.isEmpty else { return }

        Task {
            guard let url = URL(string: "\(baseURL)/api/vip/status") else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            if let (data, _) = try? await URLSession.shared.data(for: request),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let resultData = json["data"] as? [String: Any] {
                await MainActor.run {
                    self.isVip = resultData["isVip"] as? Bool ?? false
                    self.vipExpiry = resultData["expiry"] as? String ?? ""
                }
            }
        }
    }
}
