import SwiftUI
import FirebaseCore

@main
struct BuntanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var appVM: AppViewModel

    init() {
        FirebaseApp.configure()
        _appVM = State(wrappedValue: AppViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appVM)
        }
    }
}
