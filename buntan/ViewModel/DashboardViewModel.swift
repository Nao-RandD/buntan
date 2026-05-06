import Foundation
import Observation
import FirebaseFirestore

@Observable
class DashboardViewModel {
    var rankings: [UserInfo] = []
    private var rankingListener: ListenerRegistration?

    func setListener(group: String) {
        rankingListener?.remove()
        rankingListener = FirebaseManager.shared.setRankingListener { snapshot in
            let users = snapshot.documents
                .filter { $0.data()["group"] as? String == group }
                .map { doc -> UserInfo in
                    let d = doc.data()
                    return UserInfo(name: d["name"] as! String, point: d["point"] as! Int)
                }
                .sorted { $0.point > $1.point }
            DispatchQueue.main.async { self.rankings = users }
        }
    }

    func onGroupChanged(group: String) {
        setListener(group: group)
    }
}
