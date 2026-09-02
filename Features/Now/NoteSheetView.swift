import SwiftUI

// 💭 想一句：最多 50 字
// 不是日记，就是随手写给未来自己的一句话
struct NoteSheetView: View {

    let viewModel: NowViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var text: String
    @FocusState private var focused: Bool

    private let limit = 50

    init(viewModel: NowViewModel) {
        self.viewModel = viewModel
        // 如果今天已经写过了，打开时先带出来，方便改
        _text = State(initialValue: viewModel.note ?? "")
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            // ── 标题 ──
            Text("想一句")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(DS.textPrimary)

            Text("说给未来的自己，最多 \(limit) 字。")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Spacer(minLength: 6)

            // ── 输入框 ──
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.7))

                if text.isEmpty {
                    Text("今天闪过脑海里的那句话…")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(DS.textSecondary.opacity(0.7))
                        .padding(20)
                }

                TextField("", text: $text, axis: .vertical)
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(DS.textPrimary)
                    .focused($focused)
                    .padding(20)
                    .frame(minHeight: 130, alignment: .topLeading)
                    .submitLabel(.done)
            }
            .frame(width: 300)
            .onSubmit { saveAndDismiss() }

            // ── 字数（超了就变红提醒，但实际不会让超）──
            Text("\(text.count) / \(limit)")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Spacer(minLength: 6)

            // ── 存下来 ──
            PixelButton(title: "就这样", enabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                saveAndDismiss()
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(DS.background)
        // 超过 50 字：硬截断（不用弹提示，安静地剪掉就好）
        .onChange(of: text) { _, newValue in
            if newValue.count > limit {
                text = String(newValue.prefix(limit))
            }
        }
        // 打开就弹键盘，进来就能写
        .onAppear { focused = true }
    }

    private func saveAndDismiss() {
        viewModel.saveNote(text.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: DayRecord.self)
    return NoteSheetView(viewModel: NowViewModel(context: ModelContext(container)))
        .presentationDetents([.medium, .large])
}
