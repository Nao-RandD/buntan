import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) var appVM

    var body: some View {
        Group {
            if appVM.isSetup {
                MainTabView()
            } else {
                StartAppView()
            }
        }
        .environment(\.dynamicTypeSize, appVM.dynamicTypeSize)
    }
}
