import Foundation
import Observation

@Observable
class EditViewModel {
    var taskName: String
    var pointText: String
    private let originalTask: GroupTask

    init(task: GroupTask) {
        self.originalTask = task
        self.taskName = task.name
        self.pointText = "\(task.point)"
    }

    func save(group: String, onSuccess: @escaping () -> Void) {
        guard !taskName.isEmpty, let point = Int(pointText) else { return }
        let afterTask = GroupTask(group: group, name: taskName, point: point)
        FirebaseManager.shared.editDocument(before: originalTask, after: afterTask) {
            DispatchQueue.main.async { onSuccess() }
        }
    }
}
