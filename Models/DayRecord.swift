import SwiftData
import Foundation

// 一天 = 一条记录 = 一个像素
// 注意：字段和 PRD 第二十八节保持一致，以后不要轻易改这个模型
@Model
class DayRecord {
    var date: Date

    // 今日像素：6 种基础颜色之一（存 index，对应 PixelColor 的 rawValue）
    var activityColorIndex: Int?

    // 心情：自由选的颜色（存十六进制字符串，如 "FF6B6B"）
    var moodColorHex: String?

    // 涂鸦：一笔颜色 + 画的内容
    var doodleColorHex: String?
    var doodleData: Data?

    // 拍一瞬：从照片提取的主色
    var photoColorHex: String?

    // 想一句：最多 50 字
    var note: String?

    init(date: Date = .now,
         activityColorIndex: Int? = nil,
         moodColorHex: String? = nil,
         doodleColorHex: String? = nil,
         doodleData: Data? = nil,
         photoColorHex: String? = nil,
         note: String? = nil) {
        self.date = date
        self.activityColorIndex = activityColorIndex
        self.moodColorHex = moodColorHex
        self.doodleColorHex = doodleColorHex
        self.doodleData = doodleData
        self.photoColorHex = photoColorHex
        self.note = note
    }
}
