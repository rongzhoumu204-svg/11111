import SwiftUI

// 像素：整个 App 最基础的视觉单元
// 一天 = 一个像素，所有页面里的"格子"都是它
struct PixelView: View {

    let color: Color
    var size: CGFloat = 96

    var body: some View {
        // 像素 = 圆角矩形（不要用纯圆形，圆角矩形更有"像素"感）
        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            .fill(color)
            .frame(width: size, height: size)
            // 微弱光晕：颜色自己会发光的感觉（不要强阴影）
            .shadow(color: color.opacity(0.35), radius: 16, x: 0, y: 4)
    }
}

#Preview("有颜色") {
    PixelView(color: PixelColor.green.color, size: 96)
        .padding(40)
}

#Preview("空白") {
    PixelView(color: DS.emptyPixel, size: 96)
        .padding(40)
}
