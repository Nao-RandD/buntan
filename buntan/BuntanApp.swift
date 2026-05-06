import SwiftUI

@main
struct BuntanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appVM)
        }
    }
}
