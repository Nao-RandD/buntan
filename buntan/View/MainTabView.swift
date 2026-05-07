import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("ホーム", systemImage: "house") }

            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("ランキング", systemImage: "chart.bar") }
        }
    }
}
