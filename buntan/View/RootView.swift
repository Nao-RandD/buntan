import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) var appVM

    var body: some View {
        Group {
            if appVM.isSetup {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(\.dynamicTypeSize, appVM.dynamicTypeSize)
    }
}
