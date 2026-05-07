import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("ホーム", systemImage: "house") }
            .tag(0)

            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("ランキング", systemImage: "chart.bar") }
            .tag(1)
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}
