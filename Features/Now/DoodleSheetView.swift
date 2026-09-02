import SwiftUI

// ✎ 涂一下：简单 Canvas
// PRD 原话：「不是绘画工具，只是随便划两下。」
// 所以只有：选一个笔的颜色 → 划 → （可选）重来 → 存下来
//
// 技巧：笔迹坐标全部用 0~1 的「相对坐标」存
// 屏幕上画的时候乘以实际尺寸，存图的时候乘以导出尺寸
// 这样不管屏幕多大，导出的 PNG 都是同一张清晰的图
struct DoodleSheetView: View {

    let viewModel: NowViewModel

    @Environment(\.dismiss) private var dismiss

    // 一笔 = 一串点 + 一个颜色（点都是 0~1 的相对坐标）
    private struct DoodleLine: Identifiable {
        let id = UUID()
        var points: [CGPoint]
        let color: Color
    }

    // 已经落定的笔迹
    @State private var lines: [DoodleLine] = []
    // 正在画的这一笔（抬手后就归入 lines）
    @State private var currentLine: DoodleLine?
    // 笔的颜色：还是那 6 个基础色
    @State private var strokeColor: PixelColor = .purple

    // 导出尺寸（乘上 scale 就是实际像素）
    private let exportSize: CGFloat = 320

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 8)

            // ── 标题 ──
            Text("涂一下")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(DS.textPrimary)

            Text("不是画画，随便划两下就好。")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Spacer(minLength: 2)

            // ── 笔的颜色 ──
            HStack(spacing: 18) {
                ForEach(PixelColor.allCases) { pixel in
                    Circle()
                        .fill(pixel.color)
                        .frame(width: 26, height: 26)
                        .scaleEffect(strokeColor == pixel ? 1.2 : 1.0)
                        .shadow(
                            color: strokeColor == pixel ? pixel.color.opacity(0.5) : .clear,
                            radius: 6
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                strokeColor = pixel
                            }
                        }
                }
            }

            // ── 画布 ──
            GeometryReader { geo in
                Canvas { context, size in
                    // 画完的笔迹 + 正在画的这一笔
                    for line in lines {
                        stroke(context: context, line: line, size: size)
                    }
                    if let currentLine {
                        stroke(context: context, line: currentLine, size: size)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.7))
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                // 手指划过 → 记录相对坐标（0~1）
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let unit = CGPoint(
                                x: value.location.x / max(geo.size.width, 1),
                                y: value.location.y / max(geo.size.height, 1)
                            )
                            if var line = currentLine {
                                line.points.append(unit)
                                currentLine = line
                            } else {
                                // 落笔：新开一笔
                                currentLine = DoodleLine(points: [unit], color: strokeColor)
                            }
                        }
                        .onEnded { _ in
                            // 抬手：这一笔归档
                            if let line = currentLine, line.points.count > 1 {
                                lines.append(line)
                            }
                            currentLine = nil
                        }
                )
            }
            .frame(height: 300)
            .padding(.horizontal, 28)

            // ── 重来 / 存下来 ──
            HStack(spacing: 16) {
                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        lines.removeAll()
                    }
                } label: {
                    Text("重来")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(DS.textSecondary)
                        .frame(width: 96, height: 50)
                        .background(Capsule().fill(DS.emptyPixel))
                }
                .buttonStyle(.plain)
                .disabled(lines.isEmpty)

                PixelButton(title: "存下来", enabled: !lines.isEmpty) {
                    saveDoodle()
                    dismiss()
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(DS.background)
    }

    // ── 画一笔：把 0~1 的点换算成画布上的点 ──
    private func stroke(context: GraphicsContext, line: DoodleLine, size: CGSize) {
        guard let first = line.points.first else { return }
        var path = Path()
        path.move(to: CGPoint(x: first.x * size.width, y: first.y * size.height))
        for point in line.points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x * size.width, y: point.y * size.height))
        }
        context.stroke(
            path,
            with: .color(line.color),
            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
        )
    }

    // ── 存图：把笔迹渲染成一张白底 PNG ──
    private func saveDoodle() {
        let renderer = ImageRenderer(
            content: doodleSnapshot
                .frame(width: exportSize, height: exportSize)
        )
        renderer.scale = 2   // 2 倍，retina 屏上也清楚

        guard let png = renderer.uiImage?.pngData() else { return }
        viewModel.saveDoodle(colorHex: strokeColor.hexString, imageData: png)
    }

    // 导出用的视图：同样的笔迹、固定尺寸
    // 每笔单独一个 Shape，这样换色也能正确保留
    private var doodleSnapshot: some View {
        ZStack {
            Color.white
            ForEach(lines) { line in
                DoodleShape(points: line.points)
                    .stroke(
                        line.color,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                    )
            }
        }
    }
}

// 一条笔迹（把点连成 Path，坐标 0~1，画在多大的框里就自动放大到多大）
struct DoodleShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: CGPoint(x: first.x * rect.width, y: first.y * rect.height))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
        }
        return path
    }
}

#Preview {
    let container = try! ModelContainer(for: DayRecord.self)
    return DoodleSheetView(viewModel: NowViewModel(context: ModelContext(container)))
        .presentationDetents([.large])
}
