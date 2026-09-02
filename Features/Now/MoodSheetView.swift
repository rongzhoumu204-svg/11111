import SwiftUI

// ♡ 心情：自由选一个颜色
// 不是 6 色那种「今天的主色」，而是「凭感觉」——所以给一排更丰富的颜色
struct MoodSheetView: View {

    let viewModel: NowViewModel

    @Environment(\.dismiss) private var dismiss

    // 选中的颜色（hex 字符串，如 "FF8FAB"）
    @State private var selectedHex: String?

    init(viewModel: NowViewModel) {
        self.viewModel = viewModel
        // 今天已经存过心情的话，打开时先带出来，方便改
        _selectedHex = State(initialValue: viewModel.todayRecord?.moodColorHex)
    }

    // 心情调色板：6 基础色 + 6 个更「情绪」的颜色
    // hex 和显示名放一起，存库的是 hex
    private struct MoodColor: Identifiable {
        let name: String
        let hex: String
        var id: String { hex }
        var color: Color { Color(hexString: hex) ?? DS.emptyPixel }
    }

    private static let palette: [MoodColor] = [
        MoodColor(name: "红",   hex: "FF6B6B"),
        MoodColor(name: "橙",   hex: "FFA94D"),
        MoodColor(name: "黄",   hex: "FFD93D"),
        MoodColor(name: "绿",   hex: "6BCB77"),
        MoodColor(name: "蓝",   hex: "4D96FF"),
        MoodColor(name: "紫",   hex: "9B72FF"),
        MoodColor(name: "粉",   hex: "FF8FAB"),
        MoodColor(name: "玫瑰", hex: "E0577E"),
        MoodColor(name: "青",   hex: "2EC4B6"),
        MoodColor(name: "薄荷", hex: "9BE8C8"),
        MoodColor(name: "蜜桃", hex: "FFB4A2"),
        MoodColor(name: "深夜", hex: "57548B"),
    ]

    // 4 列网格
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 8)

            // ── 标题 ──
            Text("今天的心情")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(DS.textPrimary)

            Text("不用想太多，凭感觉点一个。")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Spacer(minLength: 4)

            // ── 预览：选中的颜色会出现在这里 ──
            PixelView(
                color: Color(hexString: selectedHex ?? "") ?? DS.emptyPixel,
                size: 64
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedHex)

            // 选中颜色的名字（比如「玫瑰」）
            Text(selectedName)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Spacer(minLength: 4)

            // ── 颜色网格 ──
            LazyVGrid(columns: columns, spacing: 22) {
                ForEach(Self.palette) { mood in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                            selectedHex = mood.hex
                        }
                    } label: {
                        Circle()
                            .fill(mood.color)
                            .frame(width: 44, height: 44)
                        // 选中的那个稍微放大 + 光晕，像被点亮
                            .scaleEffect(selectedHex == mood.hex ? 1.15 : 1.0)
                            .shadow(
                                color: selectedHex == mood.hex ? mood.color.opacity(0.55) : .clear,
                                radius: 10
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 32)

            Spacer(minLength: 8)

            // ── 存下来 ──
            PixelButton(title: "就这样", enabled: selectedHex != nil) {
                if let selectedHex {
                    viewModel.saveMood(hex: selectedHex)
                }
                dismiss()
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(DS.background)
    }

    private var selectedName: String {
        guard let selectedHex,
              let mood = Self.palette.first(where: { $0.hex == selectedHex }) else {
            return "…"
        }
        return mood.name
    }
}

#Preview {
    let container = try! ModelContainer(for: DayRecord.self)
    return MoodSheetView(viewModel: NowViewModel(context: ModelContext(container)))
        .presentationDetents([.medium, .large])
}
