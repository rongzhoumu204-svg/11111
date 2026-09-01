import SwiftUI

// 三 Tab 结构：此刻 / 漫游 / 光年
// 这一版先跑通「此刻」，另外两个放占位页面
struct ContentView: View {
    var body: some View {
        TabView {
            NowView()
                .tabItem {
                    Label("此刻", systemImage: "circle.grid.2x2")
                }

            WanderPlaceholderView()
                .tabItem {
                    Label("漫游", systemImage: "calendar")
                }

            LightyearPlaceholderView()
                .tabItem {
                    Label("光年", systemImage: "sparkles")
                }
        }
        .tint(DS.textPrimary)
    }
}

// 漫游占位：里程碑 2 实现
struct WanderPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundStyle(DS.ambientGlow)
            Text("漫游")
                .font(.system(.title2, design: .rounded))
                .foregroundStyle(DS.textPrimary)
            Text("穿过时间，看看你的颜色轨迹。")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(DS.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.background.ignoresSafeArea())
    }
}

// 光年占位：里程碑 3 实现
struct LightyearPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(DS.ambientGlow)
            Text("光年")
                .font(.system(.title2, design: .rounded))
                .foregroundStyle(DS.textPrimary)
            Text("一年的回响，还在酝酿中。")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(DS.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.background.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
