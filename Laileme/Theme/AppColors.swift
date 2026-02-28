import SwiftUI

struct AppColors {
    // 动态主色（跟随主题）
    static var primaryPink: Color { ThemeManager.shared.currentPrimary }
    static var lightPink: Color { ThemeManager.shared.currentLightPrimary }

    static let accentTeal = Color(hex: "5ECFB1")
    static let accentOrange = Color(hex: "FFB347")
    static let accentBlue = Color(hex: "87CEEB")

    static let periodRed = Color(hex: "FF6B6B")
    static let predictPeriod = Color(hex: "FFB3B3")
    static let ovulationOrange = Color(hex: "FFB347")
    static let ovulationHeart = Color(hex: "FF69B4")
    static let predictOvulation = Color(hex: "FFB6C1")
    static let fertileGreen = Color(hex: "81C784")

    static let cardBackground = Color(hex: "F8FBFF")
    static let background = Color(hex: "F5F8FA")
    static let bottomSheetBg = Color(hex: "E8F4F8")

    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    static let textHint = Color(hex: "B2BEC3")

    static let todayGreen = Color(hex: "5ECFB1")
    static var weekendText: Color { ThemeManager.shared.currentPrimary }

    static var navSelected: Color { ThemeManager.shared.currentPrimary }
    static let navUnselected = Color(hex: "B2BEC3")
}

// Color hex 扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
