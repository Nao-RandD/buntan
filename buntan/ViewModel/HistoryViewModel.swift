import Foundation
import Observation
import RealmSwift

extension TaskItem: Identifiable {
    public var id: String { taskId }
}

@Observable
class HistoryViewModel {
    var taskItems: [TaskItem] = []

    func fetchHistory() {
        taskItems = Array(RealmManager.shared.getTaskInRealm())
    }

    func deleteItem(_ item: TaskItem, user: String, group: String) {
        RealmManager.shared.deleteTaskItem(item: item)
        fetchHistory()
        let newTotal = RealmManager.shared.getTotalPoint()
        FirebaseManager.shared.sendDoneTask(name: user, group: group, point: newTotal) {}
    }
}
