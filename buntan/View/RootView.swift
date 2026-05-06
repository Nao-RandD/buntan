import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) var appVM

    var body: some View {
        if appVM.isSetup {
            MainTabView()
        } else {
            // Phase 4 で StartAppView() に差し替える
            Text("セットアップ画面（準備中）")
        }
    }
}
