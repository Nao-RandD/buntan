import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) var appVM

    var body: some View {
        if appVM.isSetup {
            MainTabView()
        } else {
            StartAppView()
        }
    }
}
