import SwiftUI

/// 自定义字体配置
/// 需要将 jiangcheng_yuanti.ttf 放入 Xcode 项目并在 Info.plist 中注册
struct AppFonts {
    static let fontName = "JiangChengYuanTi"

    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // 如果有自定义字体文件，使用以下方式
    // static func custom(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
    //     .custom(fontName, size: size)
    // }
}
