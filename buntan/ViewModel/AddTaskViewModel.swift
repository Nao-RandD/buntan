import Foundation
import Observation

@MainActor
@Observable
class AddTaskViewModel {
    var taskName: String = ""
    var pointText: String = ""

    func addTask(group: String, onSuccess: @escaping () -> Void) {
        guard !taskName.isEmpty, let point = Int(pointText) else { return }
        FirebaseManager.shared.addTask(name: taskName, group: group, point: point) {
            Task { @MainActor in
                self.taskName = ""
                self.pointText = ""
                onSuccess()
            }
        }
    }
}
