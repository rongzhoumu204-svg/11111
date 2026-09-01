import SwiftUI

// 核心交互：今日像素
// 像在戳一个小宇宙：
// 1. 点中央像素 → 轻微放大，6 个颜色从周围冒出来
// 2. 点某个颜色 → 它向中心飞去，汇聚成今天的像素
struct PixelPickerView: View {

    // 选中的颜色（nil = 今天还没染色）
    @Binding var selectedColor: PixelColor?

    // 是否展开颜色选择
    @State private var isExpanded = false

    // 颜色小圆点距离中心的距离
    private let orbitRadius: CGFloat = 130

    var body: some View {
        ZStack {
            // ── 第一步：6 个颜色小圆点（展开时才出现）──
            ForEach(PixelColor.allCases) { pixel in
                Circle()
                    .fill(pixel.color)
                    .frame(width: 44, height: 44)
                    .shadow(color: pixel.color.opacity(0.4), radius: 8)
                    .offset(dotOffset(for: pixel))
                // 展开时逐个弹出（有一点先后顺序，更像活的）
                    .scaleEffect(isExpanded ? 1.0 : 0.001,
                                 anchor: .center)
                    .opacity(isExpanded ? 1 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.7)
                            .delay(isExpanded ? Double(pixel.rawValue) * 0.05 : 0),
                        value: isExpanded
                    )
                    .onTapGesture { choose(pixel) }
            }

            // ── 第二步：中央的今日像素 ──
            PixelView(
                color: selectedColor?.color ?? DS.emptyPixel,
                size: 96
            )
            .scaleEffect(isExpanded ? 1.12 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isExpanded)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedColor)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                    isExpanded.toggle()
                }
            }

            // 展开时中央提示（很轻，不抢戏）
            if isExpanded {
                Text("选一个")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(DS.textSecondary)
                    .offset(y: 90)
                    .transition(.opacity)
            }
        }
    }

    // 计算 6 个圆点环绕中心的位置（每 60° 一个，从正上方开始）
    private func dotOffset(for pixel: PixelColor) -> CGSize {
        guard isExpanded else { return .zero }
        let angle = Double(pixel.rawValue) / 6.0 * 2 * .pi - .pi / 2
        return CGSize(
            width: orbitRadius * cos(angle),
            height: orbitRadius * sin(angle)
        )
    }

    // 选中某个颜色的完整流程
    private func choose(_ pixel: PixelColor) {
        // TODO（第四阶段）：播放对应音高 + 触发 Haptic
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            selectedColor = pixel
            isExpanded = false
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var color: PixelColor?
        var body: some View {
            PixelPickerView(selectedColor: $color)
                .padding(60)
                .background(DS.background)
        }
    }
    return PreviewWrapper()
}
