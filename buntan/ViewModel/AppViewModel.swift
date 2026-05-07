import Foundation
import Observation
import SwiftUI
import FirebaseFirestore

@Observable
class AppViewModel {

    static let fontSizes: [DynamicTypeSize] = [
        .medium, .large, .xLarge, .xxLarge, .xxxLarge, .accessibility1, .accessibility2
    ]
    static let fontSizeLabels = ["小", "標準", "大", "特大", "超特大", "極大", "最大（2倍）"]

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

    var fontSizeIndex: Int = 0 {
        didSet {
            UserDefaults.standard.set(fontSizeIndex, forKey: "fontSizeIndex")
            dynamicTypeSize = AppViewModel.fontSizes[fontSizeIndex]
        }
    }

    // stored property so @Observable tracks it directly
    var dynamicTypeSize: DynamicTypeSize = .large

    private var groupDeletionListener: ListenerRegistration?

    init() {
        let saved = UserDefaults.standard.object(forKey: "fontSizeIndex") != nil
            ? UserDefaults.standard.integer(forKey: "fontSizeIndex")
            : 3
        fontSizeIndex = saved
        dynamicTypeSize = AppViewModel.fontSizes[saved]
    }

    func leaveGroup() {
        stopGroupDeletionListener()
        let name = currentUser
        RealmManager.shared.deleteAllTaskItem()
        isShowTutorial = false
        currentUser = ""
        currentGroup = ""
        isSetup = false
        FirebaseManager.shared.deleteUser(name: name) {}
    }

    func deleteGroup(groupName: String) {
        stopGroupDeletionListener()
        FirebaseManager.shared.deleteGroupTasks(groupName: groupName) {
            FirebaseManager.shared.deleteGroup(name: groupName) {
                Task { @MainActor in
                    self.leaveGroup()
                }
            }
        }
    }

    func startGroupDeletionListener() {
        guard !currentGroup.isEmpty else { return }
        groupDeletionListener = FirebaseManager.shared.setGroupDeletionListener(name: currentGroup) {
            Task { @MainActor in
                self.leaveGroup()
            }
        }
    }

    func stopGroupDeletionListener() {
        groupDeletionListener?.remove()
        groupDeletionListener = nil
    }
}
