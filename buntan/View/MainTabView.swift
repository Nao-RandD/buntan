import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                // Phase 2 で HomeView() に差し替える
                Text("ホーム（準備中）")
                    .navigationTitle("ホーム")
            }
            .tabItem { Label("ホーム", systemImage: "house") }

            NavigationStack {
                // Phase 2 で DashboardView() に差し替える
                Text("ランキング（準備中）")
                    .navigationTitle("ランキング")
            }
            .tabItem { Label("ランキング", systemImage: "chart.bar") }
        }
    }
}
