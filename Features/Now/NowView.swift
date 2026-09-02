import SwiftUI
import SwiftData

// 「此刻」页面：记录今天
// 目标：3 秒完成核心记录，一打开不是表单，是一个可以戳的像素
struct NowView: View {

    // 数据管家：负责今天的 DayRecord 读写
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: NowViewModel?

    // 刚染上色时，显示「今天被染上了。」1.5 秒后自然消失
    @State private var showBlessing = false

    // 四个可选功能弹层：心情 / 涂一下 / 拍一瞬 / 想一句
    enum EntrySheet: String, Identifiable {
        case mood, doodle, photo, note
        var id: String { rawValue }
    }
    @State private var activeSheet: EntrySheet?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                DS.background.ignoresSafeArea()
            }
        }
        // 创建 viewModel（只需要一次）
        .task {
            if viewModel == nil {
                viewModel = NowViewModel(context: modelContext)
            }
        }
    }

    // ── 页面主体 ──
    private func content(_ viewModel: NowViewModel) -> some View {
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
            PixelPickerView(selectedColor: colorBinding(viewModel))

            Spacer(minLength: 30)

            // ── 中央下方的一句话 ──
            Text(belowText)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(DS.textSecondary)
                .animation(.easeInOut(duration: 0.4), value: belowText)

            Spacer(minLength: 24)

            // ── 第二层记录：可选，不是必填 ──
            if viewModel.selectedColor != nil {
                VStack(spacing: 18) {
                    Text("今天已经有颜色了 ✨")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(DS.textSecondary)

                    HStack(spacing: 28) {
                        entryButton(icon: "♡", label: "心情",
                                    filledColor: viewModel.moodColor) {
                            activeSheet = .mood
                        }
                        entryButton(icon: "✎", label: "涂一下",
                                    filledColor: viewModel.doodleColor) {
                            activeSheet = .doodle
                        }
                        entryButton(icon: "◉", label: "拍一瞬",
                                    filledColor: viewModel.photoColor) {
                            activeSheet = .photo
                        }
                        entryButton(icon: "💭", label: "想一句",
                                    filledColor: viewModel.note == nil ? nil : DS.textPrimary) {
                            activeSheet = .note
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.selectedColor)
        // 四个功能弹层（present 为底部 Sheet，可以往下拖关闭）
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .mood:   MoodSheetView(viewModel: viewModel)
            case .doodle: DoodleSheetView(viewModel: viewModel)
            case .photo:  PhotoSheetView(viewModel: viewModel)
            case .note:   NoteSheetView(viewModel: viewModel)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(DS.background)
        }
    }

    // ── 私有辅助 ──

    // 中央下方那句话的状态机
    private var belowText: String {
        if viewModel?.selectedColor == nil {
            return "今天是什么颜色呢？"
        } else if showBlessing {
            return "今天被染上了。"
        } else {
            return "还想塞点什么？"
        }
    }

    // 把 viewModel 的颜色包装成 PixelPickerView 需要的 Binding
    // 注意：只有「用户真的选了颜色」才触发祝福语
    // （App 重启恢复今天的颜色时，不重新祝福一遍）
    private func colorBinding(_ viewModel: NowViewModel) -> Binding<PixelColor?> {
        Binding(
            get: { viewModel.selectedColor },
            set: { newValue in
                guard let newValue else { return }
                viewModel.chooseColor(newValue)
                revealBlessing()
            }
        )
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

    // 四个可选入口
    // filledColor：今天已经存过的内容，会在图标右上角显示一个小色点
    private func entryButton(icon: String, label: String,
                             filledColor: Color?,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Text(icon)
                        .font(.system(size: 24, design: .rounded))
                        .foregroundStyle(DS.textPrimary)

                    // 「今天塞过东西了」的小标记
                    if let filledColor {
                        Circle()
                            .fill(filledColor)
                            .frame(width: 9, height: 9)
                            .offset(x: 6, y: -4)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                Text(label)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(DS.textSecondary)
            }
            .frame(width: 64, height: 64)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: filledColor != nil)
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
        .modelContainer(for: DayRecord.self, inMemory: true)
}
