import Foundation
import Observation
import FirebaseFirestore

@MainActor
@Observable
class HomeViewModel {
    var groupTasks: [GroupTask] = []
    var selectedTask: GroupTask? = nil

    func setListener(group: String) {
        FirebaseManager.shared.setListener { snapshot in
            let tasks = snapshot.documents
                .filter { $0.data()["group"] as? String == group }
                .map { doc -> GroupTask in
                    let d = doc.data()
                    return GroupTask(
                        group: d["group"] as! String,
                        name:  d["name"]  as! String,
                        point: d["point"] as! Int
                    )
                }
            Task { @MainActor in self.groupTasks = tasks }
        }
    }

    func sendTask(user: String, group: String, onSuccess: @escaping () -> Void) {
        guard let task = selectedTask else { return }
        RealmManager.shared.writeTaskItem(task: task.name, point: task.point)
        let point = RealmManager.shared.getTotalPoint()
        FirebaseManager.shared.sendDoneTask(name: user, group: group, point: point) {
            Task { @MainActor in
                self.selectedTask = nil
                onSuccess()
            }
        }
    }

    func deleteTask(_ task: GroupTask) {
        FirebaseManager.shared.deleteDocument(target: task) {}
    }

    func onGroupChanged(group: String) {
        RealmManager.shared.deleteAllTaskItem()
        selectedTask = nil
        setListener(group: group)
    }
}
