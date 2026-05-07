import SwiftUI

struct MainTabView: View {
    @Environment(AppViewModel.self) var appVM

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
        .onAppear { appVM.startGroupDeletionListener() }
        .onDisappear { appVM.stopGroupDeletionListener() }
    }
}
