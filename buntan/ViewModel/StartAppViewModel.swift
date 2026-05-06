import Foundation
import Observation

@MainActor
@Observable
class StartAppViewModel {
    var userName: String = ""
    var groups: [GroupDetail] = []
    var selectedGroupIndex: Int = 0

    var selectedGroup: GroupDetail? {
        guard groups.indices.contains(selectedGroupIndex) else { return nil }
        return groups[selectedGroupIndex]
    }

    func fetchGroups() {
        FirebaseManager.shared.fetchGroups { [weak self] fetched in
            Task { @MainActor [weak self] in
                self?.groups = fetched
            }
        }
    }

    func completeSetup(appVM: AppViewModel) {
        guard !userName.isEmpty, let group = selectedGroup else { return }
        appVM.currentUser = userName
        appVM.currentGroup = group.name
        FirebaseManager.shared.setupUser(name: userName, group: group.name) {
            Task { @MainActor in
                appVM.isSetup = true
            }
        }
    }
}
