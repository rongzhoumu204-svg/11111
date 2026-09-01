import SwiftUI
import SwiftData

// App 入口
// .modelContainer 告诉 SwiftData：全局使用 DayRecord 这个数据模型
@main
struct PixelLightyearApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DayRecord.self)
    }
}
