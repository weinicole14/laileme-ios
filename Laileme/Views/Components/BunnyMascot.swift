import SwiftUI

/// 站立的兔子吉祥物
struct BunnyMascot: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // 左耳
            var leftEar = Path()
            leftEar.move(to: CGPoint(x: w * 0.25, y: h * 0.45))
            leftEar.addQuadCurve(to: CGPoint(x: w * 0.3, y: h * 0.05), control: CGPoint(x: w * 0.15, y: h * 0.1))
            leftEar.addQuadCurve(to: CGPoint(x: w * 0.35, y: h * 0.45), control: CGPoint(x: w * 0.4, y: h * 0.1))
            leftEar.closeSubpath()
            context.fill(leftEar, with: .color(Color(hex: "FFF5F5")))

            // 左耳内部粉色
            var leftInner = Path()
            leftInner.move(to: CGPoint(x: w * 0.27, y: h * 0.42))
            leftInner.addQuadCurve(to: CGPoint(x: w * 0.3, y: h * 0.1), control: CGPoint(x: w * 0.2, y: h * 0.15))
            leftInner.addQuadCurve(to: CGPoint(x: w * 0.33, y: h * 0.42), control: CGPoint(x: w * 0.37, y: h * 0.15))
            leftInner.closeSubpath()
            context.fill(leftInner, with: .color(Color(hex: "FFB6C1")))

            // 右耳
            var rightEar = Path()
            rightEar.move(to: CGPoint(x: w * 0.65, y: h * 0.45))
            rightEar.addQuadCurve(to: CGPoint(x: w * 0.7, y: h * 0.05), control: CGPoint(x: w * 0.6, y: h * 0.1))
            rightEar.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.45), control: CGPoint(x: w * 0.85, y: h * 0.1))
            rightEar.closeSubpath()
            context.fill(rightEar, with: .color(Color(hex: "FFF5F5")))

            // 右耳内部粉色
            var rightInner = Path()
            rightInner.move(to: CGPoint(x: w * 0.67, y: h * 0.42))
            rightInner.addQuadCurve(to: CGPoint(x: w * 0.7, y: h * 0.1), control: CGPoint(x: w * 0.63, y: h * 0.15))
            rightInner.addQuadCurve(to: CGPoint(x: w * 0.73, y: h * 0.42), control: CGPoint(x: w * 0.8, y: h * 0.15))
            rightInner.closeSubpath()
            context.fill(rightInner, with: .color(Color(hex: "FFB6C1")))

            // 头部椭圆
            let headRect = CGRect(x: w * 0.15, y: h * 0.35, width: w * 0.7, height: h * 0.55)
            context.fill(Path(ellipseIn: headRect), with: .color(Color(hex: "FFF5F5")))

            // 左眼
            context.fill(Path(ellipseIn: CGRect(x: w * 0.31, y: h * 0.51, width: w * 0.08, height: w * 0.08)),
                         with: .color(Color(hex: "2D3436")))
            // 右眼
            context.fill(Path(ellipseIn: CGRect(x: w * 0.61, y: h * 0.51, width: w * 0.08, height: w * 0.08)),
                         with: .color(Color(hex: "2D3436")))
            // 眼睛高光
            context.fill(Path(ellipseIn: CGRect(x: w * 0.345, y: h * 0.525, width: w * 0.03, height: w * 0.03)),
                         with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.645, y: h * 0.525, width: w * 0.03, height: w * 0.03)),
                         with: .color(.white))

            // 鼻子
            context.fill(Path(ellipseIn: CGRect(x: w * 0.47, y: h * 0.62, width: w * 0.06, height: w * 0.06)),
                         with: .color(Color(hex: "FFB6C1")))

            // 腮红
            context.fill(Path(ellipseIn: CGRect(x: w * 0.16, y: h * 0.59, width: w * 0.12, height: w * 0.12)),
                         with: .color(Color(hex: "FFB6C1").opacity(0.4)))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.72, y: h * 0.59, width: w * 0.12, height: w * 0.12)),
                         with: .color(Color(hex: "FFB6C1").opacity(0.4)))

            // 前爪
            context.fill(Path(ellipseIn: CGRect(x: w * 0.2, y: h * 0.8, width: w * 0.2, height: h * 0.12)),
                         with: .color(Color(hex: "FFF5F5")))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.6, y: h * 0.8, width: w * 0.2, height: h * 0.12)),
                         with: .color(Color(hex: "FFF5F5")))
        }
        .frame(width: 70, height: 84)
    }
}

/// 趴着的兔子吉祥物
struct BunnyMascotLying: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // 身体
            context.fill(Path(ellipseIn: CGRect(x: w * 0.35, y: h * 0.15, width: w * 0.6, height: h * 0.5)),
                         with: .color(Color(hex: "FFF5F5")))

            // 左耳
            var leftEar = Path()
            leftEar.move(to: CGPoint(x: w * 0.18, y: h * 0.38))
            leftEar.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.0), control: CGPoint(x: w * 0.08, y: h * 0.02))
            leftEar.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.38), control: CGPoint(x: w * 0.32, y: h * 0.05))
            leftEar.closeSubpath()
            context.fill(leftEar, with: .color(Color(hex: "FFF5F5")))

            var leftInner = Path()
            leftInner.move(to: CGPoint(x: w * 0.2, y: h * 0.35))
            leftInner.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.05), control: CGPoint(x: w * 0.13, y: h * 0.08))
            leftInner.addQuadCurve(to: CGPoint(x: w * 0.26, y: h * 0.35), control: CGPoint(x: w * 0.29, y: h * 0.1))
            leftInner.closeSubpath()
            context.fill(leftInner, with: .color(Color(hex: "FFB6C1")))

            // 右耳
            var rightEar = Path()
            rightEar.move(to: CGPoint(x: w * 0.32, y: h * 0.38))
            rightEar.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.0), control: CGPoint(x: w * 0.28, y: h * 0.05))
            rightEar.addQuadCurve(to: CGPoint(x: w * 0.42, y: h * 0.38), control: CGPoint(x: w * 0.48, y: h * 0.05))
            rightEar.closeSubpath()
            context.fill(rightEar, with: .color(Color(hex: "FFF5F5")))

            var rightInner = Path()
            rightInner.move(to: CGPoint(x: w * 0.34, y: h * 0.35))
            rightInner.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.05), control: CGPoint(x: w * 0.31, y: h * 0.1))
            rightInner.addQuadCurve(to: CGPoint(x: w * 0.4, y: h * 0.35), control: CGPoint(x: w * 0.45, y: h * 0.1))
            rightInner.closeSubpath()
            context.fill(rightInner, with: .color(Color(hex: "FFB6C1")))

            // 头部
            context.fill(Path(ellipseIn: CGRect(x: w * 0.1, y: h * 0.25, width: w * 0.4, height: h * 0.45)),
                         with: .color(Color(hex: "FFF5F5")))

            // 眼睛
            context.fill(Path(ellipseIn: CGRect(x: w * 0.195, y: h * 0.395, width: w * 0.05, height: w * 0.05)),
                         with: .color(Color(hex: "2D3436")))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.355, y: h * 0.395, width: w * 0.05, height: w * 0.05)),
                         with: .color(Color(hex: "2D3436")))

            // 鼻子
            context.fill(Path(ellipseIn: CGRect(x: w * 0.28, y: h * 0.48, width: w * 0.04, height: w * 0.04)),
                         with: .color(Color(hex: "FFB6C1")))

            // 腮红
            context.fill(Path(ellipseIn: CGRect(x: w * 0.105, y: h * 0.465, width: w * 0.07, height: w * 0.07)),
                         with: .color(Color(hex: "FFB6C1").opacity(0.4)))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.425, y: h * 0.465, width: w * 0.07, height: w * 0.07)),
                         with: .color(Color(hex: "FFB6C1").opacity(0.4)))

            // 前爪
            context.fill(Path(ellipseIn: CGRect(x: w * 0.15, y: h * 0.65, width: w * 0.13, height: h * 0.22)),
                         with: .color(Color(hex: "FFF5F5")))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.33, y: h * 0.65, width: w * 0.13, height: h * 0.22)),
                         with: .color(Color(hex: "FFF5F5")))

            // 尾巴
            context.fill(Path(ellipseIn: CGRect(x: w * 0.87, y: h * 0.25, width: w * 0.1, height: w * 0.1)),
                         with: .color(Color(hex: "FFF5F5")))
        }
        .frame(width: 80, height: 56)
    }
}
