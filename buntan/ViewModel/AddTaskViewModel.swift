import Foundation
import Observation

@Observable
class AddTaskViewModel {
    var taskName: String = ""
    var pointText: String = ""

    func addTask(group: String, onSuccess: @escaping () -> Void) {
        guard !taskName.isEmpty, let point = Int(pointText) else { return }
        FirebaseManager.shared.addTask(name: taskName, group: group, point: point) {
            DispatchQueue.main.async {
                self.taskName = ""
                self.pointText = ""
                onSuccess()
            }
        }
    }
}
