import SwiftUI

// 统一的按钮：圆角胶囊、轻轻的，符合「UI 是配角」的原则
// 四个记录功能的弹层底部都用它
struct PixelButton: View {

    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(enabled ? Color.white : DS.textSecondary)
                .frame(width: 200, height: 50)
                .background(
                    Capsule()
                        .fill(
                            enabled
                                ? AnyShapeStyle(Color(hex: 0x9B72FF))
                                : AnyShapeStyle(DS.emptyPixel)
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .animation(.easeInOut(duration: 0.25), value: enabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelButton(title: "就这样") {}
        PixelButton(title: "就这样", enabled: false) {}
    }
    .padding(40)
    .background(DS.background)
}
