import SwiftUI

// 「此刻」页面：记录今天
// 目标：3 秒完成核心记录，一打开不是表单，是一个可以戳的像素
struct NowView: View {

    @State private var selectedColor: PixelColor?

    // 刚染上色时，显示「今天被染上了。」1.5 秒后自然消失
    @State private var showBlessing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            // ── 顶部：日期 ──
            Text("像素光年")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Text(todayDateString)
                .font(.system(size: 48, weight: .medium, design: .rounded))
                .foregroundStyle(DS.textPrimary)
                .padding(.top, 6)

            Text(weekdayString + " · 今日像素")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(DS.textSecondary)
                .padding(.top, 4)

            Spacer(minLength: 30)

            // ── 中央：今日像素 ──
            PixelPickerView(selectedColor: $selectedColor)
                .onChange(of: selectedColor) { _, _ in
                    revealBlessing()
                }

            Spacer(minLength: 30)

            // ── 中央下方的一句话 ──
            Text(belowText)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(DS.textSecondary)
                .animation(.easeInOut(duration: 0.4), value: belowText)

            Spacer(minLength: 24)

            // ── 第二层记录：可选，不是必填 ──
            if selectedColor != nil {
                VStack(spacing: 18) {
                    Text("今天已经有颜色了 ✨")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(DS.textSecondary)

                    HStack(spacing: 28) {
                        entryButton(icon: "♡", label: "心情")
                        entryButton(icon: "✎", label: "涂一下")
                        entryButton(icon: "◉", label: "拍一瞬")
                        entryButton(icon: "💭", label: "想一句")
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedColor)
    }

    // ── 私有辅助 ──

    // 中央下方那句话的状态机
    private var belowText: String {
        if selectedColor == nil {
            return "今天是什么颜色呢？"
        } else if showBlessing {
            return "今天被染上了。"
        } else {
            return "还想塞点什么？"
        }
    }

    // 背景主色 + 极轻微的紫色光晕（不要抢主体）
    private var backgroundView: some View {
        ZStack {
            DS.background
            RadialGradient(
                colors: [DS.ambientGlow.opacity(0.35), .clear],
                center: .center,
                startRadius: 60,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }

    // 染色成功 → 显示「今天被染上了。」1.5 秒后消失
    private func revealBlessing() {
        showBlessing = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeInOut(duration: 0.4)) {
                showBlessing = false
            }
        }
    }

    // 四个可选入口（这一版只是占位，功能后面逐个加）
    private func entryButton(icon: String, label: String) -> some View {
        Button {
            // TODO（后续里程碑）：心情 / 涂鸦 / 照片 / 想一句
        } label: {
            VStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: 24, design: .rounded))
                    .foregroundStyle(DS.textPrimary)
                Text(label)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(DS.textSecondary)
            }
            .frame(width: 64, height: 64)
        }
        .buttonStyle(.plain)
    }

    // 今天的日期，如「9.02」
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M.dd"
        return formatter.string(from: .now)
    }

    // 星期几，如「星期三」
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: .now)
    }
}

#Preview {
    NowView()
}
