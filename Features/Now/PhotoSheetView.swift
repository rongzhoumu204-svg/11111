import SwiftUI
import PhotosUI
import CoreImage

// ◉ 拍一瞬：从相册选一张照片，自动提取主色
// 「拍一瞬」的意义不是保存照片，而是把那一刻的颜色偷回来
struct PhotoSheetView: View {

    let viewModel: NowViewModel

    @Environment(\.dismiss) private var dismiss

    // PhotosUI 的选择器：选中的照片item
    @State private var photoItem: PhotosPickerItem?

    // 选中后解析出来的东西
    @State private var previewImage: UIImage?
    @State private var extractedHex: String?

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 8)

            // ── 标题 ──
            Text("拍一瞬")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(DS.textPrimary)

            Text("选一张照片，把那一刻的颜色偷回来。")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(DS.textSecondary)

            Spacer(minLength: 4)

            // ── 照片预览 + 提取出的主色像素 ──
            ZStack {
                if let previewImage {
                    // 照片本体：圆角 + 轻微阴影
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)

                    // 提取出的主色像素「贴」在照片角上
                    if let extractedHex {
                        PixelView(
                            color: Color(hexString: extractedHex) ?? DS.emptyPixel,
                            size: 52
                        )
                        .offset(x: 96, y: 96)
                        .shadow(color: .black.opacity(0.15), radius: 6)
                        .transition(.scale.combined(with: .opacity))
                    }
                } else {
                    // 还没选照片的占位
                    VStack(spacing: 10) {
                        Text("◉")
                            .font(.system(size: 40, design: .rounded))
                            .foregroundStyle(DS.emptyPixel)
                        Text("还没有照片")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(DS.textSecondary)
                    }
                    .frame(width: 220, height: 220)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.6))
                    )
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: previewImage)

            Spacer(minLength: 4)

            // ── 选照片（可以反复换，直到满意）──
            PhotosPicker(selection: $photoItem, matching: .images) {
                Text(previewImage == nil ? "选一张照片" : "换一张")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(DS.textPrimary)
                    .frame(width: 160, height: 46)
                    .background(Capsule().fill(DS.emptyPixel))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 4)

            // ── 存下来 ──
            PixelButton(title: "就这个颜色", enabled: extractedHex != nil) {
                if let extractedHex {
                    viewModel.savePhoto(hex: extractedHex)
                }
                dismiss()
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(DS.background)
        // 选完照片 → 读数据 → 提取主色
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                guard let data = try? await newItem.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    previewImage = image
                    extractedHex = Self.averageHex(of: image)
                }
            }
        }
    }

    // ── 主色提取 ──
    // 用 CoreImage 的 CIAreaAverage 滤镜：把整张图平均成一个像素
    // 不是最精确的「主色」，但对天空、草地、日落这种照片足够准
    static func averageHex(of image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ]), let output = filter.outputImage else { return nil }

        // 把输出渲染成 1×1 像素，读出 RGBA
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(
            output,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        return String(format: "%02X%02X%02X", pixel[0], pixel[1], pixel[2])
    }
}

#Preview {
    let container = try! ModelContainer(for: DayRecord.self)
    return PhotoSheetView(viewModel: NowViewModel(context: ModelContext(container)))
        .presentationDetents([.medium, .large])
}
