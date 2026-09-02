import SwiftUI
import SwiftData
import Observation

// 「此刻」页面的数据管家：
// 页面 UI 只管好看，所有「今天的记录存哪、怎么读出来」都归它管
// 今天没有记录时第一次保存会自动创建，之后一直复用同一条
@Observable
final class NowViewModel {

    // 今天这条记录（nil = 今天什么都还没留下）
    private(set) var todayRecord: DayRecord?

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        loadToday()
    }

    // ── 今日像素（6 色之一）──

    var selectedColor: PixelColor? {
        PixelColor.from(index: todayRecord?.activityColorIndex)
    }

    func chooseColor(_ color: PixelColor) {
        record().activityColorIndex = color.rawValue
        save()
    }

    // ── 心情：自由选的颜色 ──

    var moodColor: Color? {
        guard let hex = todayRecord?.moodColorHex else { return nil }
        return Color(hexString: hex)
    }

    func saveMood(hex: String) {
        record().moodColorHex = hex
        save()
    }

    // ── 涂一下：一笔颜色 + 画的图案 ──

    var doodleColor: Color? {
        guard let hex = todayRecord?.doodleColorHex else { return nil }
        return Color(hexString: hex)
    }

    var doodleImage: UIImage? {
        guard let data = todayRecord?.doodleData else { return nil }
        return UIImage(data: data)
    }

    func saveDoodle(colorHex: String, imageData: Data) {
        let r = record()
        r.doodleColorHex = colorHex
        r.doodleData = imageData
        save()
    }

    // ── 拍一瞬：照片提取的主色 ──

    var photoColor: Color? {
        guard let hex = todayRecord?.photoColorHex else { return nil }
        return Color(hexString: hex)
    }

    func savePhoto(hex: String) {
        record().photoColorHex = hex
        save()
    }

    // ── 想一句：最多 50 字 ──

    var note: String? {
        todayRecord?.note
    }

    func saveNote(_ text: String) {
        record().note = text.isEmpty ? nil : text
        save()
    }

    // ── 内部工具 ──

    // 拿到「今天这条记录」：有就返回，没有就先创建
    // 这就是 PRD 说的「可选而不是必填」——任何一次轻戳都算完成
    private func record() -> DayRecord {
        if let todayRecord { return todayRecord }
        let newRecord = DayRecord(date: Calendar.current.startOfDay(for: .now))
        context.insert(newRecord)
        todayRecord = newRecord
        return newRecord
    }

    // 找到今天（00:00 ~ 24:00）的那条记录
    private func loadToday() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return }

        let startOfDay = start
        let endOfDay = end
        let descriptor = FetchDescriptor<DayRecord>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        todayRecord = (try? context.fetch(descriptor))?.first
    }

    private func save() {
        try? context.save()
    }
}
