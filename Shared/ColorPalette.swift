import SwiftUI

// 6 种基础颜色：整个 App 的调色板
// rawValue 会存进 DayRecord.activityColorIndex，顺序不要改
enum PixelColor: Int, CaseIterable, Identifiable {
    case red = 0
    case orange = 1
    case yellow = 2
    case green = 3
    case blue = 4
    case purple = 5

    var id: Int { rawValue }

    // 中文名（给用户看的）
    var name: String {
        switch self {
        case .red:    return "红"
        case .orange: return "橙"
        case .yellow: return "黄"
        case .green:  return "绿"
        case .blue:   return "蓝"
        case .purple: return "紫"
        }
    }

    // 对应音高（第二十五节：颜色不仅能看，还能听）
    var noteName: String {
        switch self {
        case .red:    return "Do"
        case .orange: return "Re"
        case .yellow: return "Mi"
        case .green:  return "Fa"
        case .blue:   return "Sol"
        case .purple: return "La"
        }
    }

    // 实际颜色
    var color: Color {
        switch self {
        case .red:    return Color(hex: 0xFF6B6B)
        case .orange: return Color(hex: 0xFFA94D)
        case .yellow: return Color(hex: 0xFFD93D)
        case .green:  return Color(hex: 0x6BCB77)
        case .blue:   return Color(hex: 0x4D96FF)
        case .purple: return Color(hex: 0x9B72FF)
        }
    }

    // 根据存的 index 反查颜色（DayRecord 里存的是 Int）
    static func from(index: Int?) -> PixelColor? {
        guard let index else { return nil }
        return PixelColor(rawValue: index)
    }

    // 十六进制字符串（如 "FF6B6B"），涂鸦等地方存库时用
    var hexString: String {
        switch self {
        case .red:    return "FF6B6B"
        case .orange: return "FFA94D"
        case .yellow: return "FFD93D"
        case .green:  return "6BCB77"
        case .blue:   return "4D96FF"
        case .purple: return "9B72FF"
        }
    }
}
