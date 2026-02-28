import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentThemeIndex: Int {
        didSet {
            UserDefaults.standard.set(currentThemeIndex, forKey: "theme_index")
        }
    }

    struct ThemePreset {
        let name: String
        let primary: Color
        let lightPrimary: Color
    }

    let themes: [ThemePreset] = [
        ThemePreset(name: "樱花粉", primary: Color(hex: "FF6B9D"), lightPrimary: Color(hex: "FFF0F5")),
        ThemePreset(name: "薰衣草", primary: Color(hex: "9B59B6"), lightPrimary: Color(hex: "F3E5F5")),
        ThemePreset(name: "天空蓝", primary: Color(hex: "5DADE2"), lightPrimary: Color(hex: "E8F4FD")),
        ThemePreset(name: "薄荷绿", primary: Color(hex: "5ECFB1"), lightPrimary: Color(hex: "E8F8F5")),
        ThemePreset(name: "珊瑚橙", primary: Color(hex: "FF7675"), lightPrimary: Color(hex: "FFF3F0")),
        ThemePreset(name: "蜜桃粉", primary: Color(hex: "FD79A8"), lightPrimary: Color(hex: "FFF0F6")),
    ]

    var currentPrimary: Color {
        themes[safe: currentThemeIndex]?.primary ?? themes[0].primary
    }

    var currentLightPrimary: Color {
        themes[safe: currentThemeIndex]?.lightPrimary ?? themes[0].lightPrimary
    }

    private init() {
        self.currentThemeIndex = UserDefaults.standard.integer(forKey: "theme_index")
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
