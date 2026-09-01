import SwiftUI

// 设计系统：颜色、字体统一在这里管理
// 原则：颜色是主角，UI 是配角
enum DS {

    // 主背景：PRD 第二十节 #F8F5FE
    static let background = Color(hex: 0xF8F5FE)

    // 还没有颜色的像素：几乎是看不见的浅灰紫
    static let emptyPixel = Color(hex: 0xE6E2F0)

    // 文字
    static let textPrimary = Color(hex: 0x3C3489)
    static let textSecondary = Color(hex: 0x8B85B0)

    // 极轻微的紫色光晕（背景用，不要抢主体）
    static let ambientGlow = Color(hex: 0xCECBF6)
}

// 十六进制颜色初始化：Color(hex: 0xFF6B6B)
extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
