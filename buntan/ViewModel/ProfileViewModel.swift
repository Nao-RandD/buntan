import Foundation
import Observation

@MainActor
@Observable
class ProfileViewModel {
    var userName: String = UserDefaults.standard.string(forKey: "User") ?? ""
    var groups: [GroupDetail] = []
    var selectedGroupIndex: Int = 0

    func fetchGroups(currentGroup: String) {
        FirebaseManager.shared.fetchGroups { [weak self] fetched in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.groups = fetched
                if let idx = fetched.firstIndex(where: { $0.name == currentGroup }) {
                    self.selectedGroupIndex = idx
                }
            }
        }
    }

    func saveUserName(appVM: AppViewModel) {
        appVM.currentUser = userName
    }

    var selectedGroup: GroupDetail? {
        guard groups.indices.contains(selectedGroupIndex) else { return nil }
        return groups[selectedGroupIndex]
    }
}
