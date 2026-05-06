import Foundation
import Observation

@Observable
class AppViewModel {

    var isSetup: Bool = UserDefaults.standard.bool(forKey: "isSetup") {
        didSet { UserDefaults.standard.set(isSetup, forKey: "isSetup") }
    }

    var currentUser: String = UserDefaults.standard.string(forKey: "User") ?? "" {
        didSet { UserDefaults.standard.set(currentUser, forKey: "User") }
    }

    var currentGroup: String = UserDefaults.standard.string(forKey: "Group") ?? "" {
        didSet { UserDefaults.standard.set(currentGroup, forKey: "Group") }
    }

    var isShowTutorial: Bool = UserDefaults.standard.bool(forKey: "isShowTutorial") {
        didSet { UserDefaults.standard.set(isShowTutorial, forKey: "isShowTutorial") }
    }
}
