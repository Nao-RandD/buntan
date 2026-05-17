//
//  FirebaseManager.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/10/30.
//

import FirebaseFirestore

enum FirebaseError: Error {
    case editError
    case addTaskError
    case addGroupError
    case sendDoneError
}

class FirebaseManager {

    public static let shared = FirebaseManager()

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {}

    func getGroup() {

    }

    func setData() {
        
    }

    func addTask(name: String, group: String, point: Int, completion: @escaping () -> Void) {
        db.collection("task").addDocument(data: [
            "group": group,
            "name": name,
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
                print("Document successfully written!")
            }
        }
    }

    func addGroup(name: String, password: String?, owner: String, completion: @escaping () -> Void) {
        db.collection("group").document(name).setData([
            "name": name, "isPassword": password != nil, "password": password ?? "", "owner": owner
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
                print("Document successfully written!")
            }
        }
    }

    func sendDoneTask(name: String, group: String, point: Int, completion: @escaping () -> Void) {
        db.collection("users").document(name).setData([
            "name": name,
            "group": group,
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
                print("Document successfully written!")
            }
        }
    }

    func deleteGroupTask() {

    }

    func setListener(completion: @escaping (QuerySnapshot) -> Void) {
        listener = db.collection("task").addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                completion(snapshot)
            }
        }
    }

    func getDocument() {
        db.collection("task").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }

        }
    }

    func deleteDocument(target task: GroupTask,
                        completion: @escaping () -> Void) {
        var targetId = ""
        db.collection("task").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let _name = data["name"] as? String, _name == task.name,
                       let _group = data["group"] as? String, _group == task.group {
                        print("変更対象のタスクIDは", document.documentID)
                        targetId = document.documentID
                    }
                    print("\(document.documentID) => \(document.data())")
                }

                guard !targetId.isEmpty else {
                    print("一致するIDが見つかりませんでした")
                    return
                }

                self.db.collection("task").document(targetId).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                        completion()
                    }
                }
            }
        }
    }
        

    func editDocument(before beforeTask: GroupTask,
                      after afterTask: GroupTask,
                      completion: @escaping () -> Void) {
        var targetId = ""
        db.collection("task").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let _name = data["name"] as? String, _name == beforeTask.name,
                       let _group = data["group"] as? String, _group == beforeTask.group {
                        print("変更対象のタスクIDは", document.documentID)
                        targetId = document.documentID
                    }
                    print("\(document.documentID) => \(document.data())")
                }

                guard !targetId.isEmpty else {
                    print("一致するIDが見つかりませんでした")
                    return
                }

                // 取得したIDをもとに修正
                let sfReference = self.db.collection("task").document(targetId)

                self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.updateData(["name": afterTask.name], forDocument: sfReference)
                    transaction.updateData(["group": afterTask.group], forDocument: sfReference)
                    transaction.updateData(["point": afterTask.point], forDocument: sfReference)

                    print("書き換え前：", beforeTask.name)
                    print("書き換え後：", afterTask.name)

                    completion()

                    return nil
                }, completion: { (object, error) in
                    if let error = error {
                        print("Transaction failed: \(error)")
                    } else {
                        print("Transaction successfully committed!")
                    }
                })
            }

        }
    }

    func setRankingListener(completion: @escaping (QuerySnapshot) -> Void) -> ListenerRegistration {
        return db.collection("users").addSnapshotListener { snapshot, _ in
            if let snapshot = snapshot { completion(snapshot) }
        }
    }

    func fetchGroups(completion: @escaping ([GroupDetail]) -> Void) {
        db.collection("group").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else { return }
            let groups = snapshot.documents.compactMap { doc -> GroupDetail? in
                let d = doc.data()
                guard let name = d["name"] as? String else { return nil }
                let isPassword: Bool
                if let flag = d["isPassword"] as? Bool {
                    isPassword = flag
                } else if let flag = d["isPassword"] as? Int {
                    isPassword = flag == 1
                } else {
                    isPassword = false
                }
                let password = (d["password"] as? String) ?? ""
                let owner = (d["owner"] as? String) ?? ""
                return GroupDetail(name: name, isPassword: isPassword, password: password, owner: owner)
            }
            completion(groups)
        }
    }

    func setupUser(name: String, group: String, completion: @escaping () -> Void) {
        db.collection("users").document(name).setData(
            ["name": name, "group": group, "point": 0],
            merge: true
        ) { err in
            if let err = err {
                print("Error registering user: \(err)")
            } else {
                completion()
            }
        }
    }

    func fetchGroupOwner(name: String, completion: @escaping (String) -> Void) {
        db.collection("group").document(name).getDocument { snapshot, _ in
            let owner = (snapshot?.data()?["owner"] as? String) ?? ""
            completion(owner)
        }
    }

    func renameGroup(oldName: String, newName: String, owner: String, completion: @escaping () -> Void) {
        db.collection("group").document(oldName).getDocument { snapshot, _ in
            let data = snapshot?.data() ?? [:]
            let isPassword = (data["isPassword"] as? Bool) ?? false
            let password = (data["password"] as? String) ?? ""
            self.db.collection("group").document(newName).setData([
                "name": newName, "isPassword": isPassword, "password": password, "owner": owner
            ]) { _ in
                self.db.collection("task").whereField("group", isEqualTo: oldName).getDocuments { tSnap, _ in
                    self.db.collection("users").whereField("group", isEqualTo: oldName).getDocuments { uSnap, _ in
                        let batch = self.db.batch()
                        tSnap?.documents.forEach { batch.updateData(["group": newName], forDocument: $0.reference) }
                        uSnap?.documents.forEach { batch.updateData(["group": newName], forDocument: $0.reference) }
                        batch.commit { _ in
                            self.db.collection("group").document(oldName).delete { _ in completion() }
                        }
                    }
                }
            }
        }
    }

    func updateGroupPassword(name: String, isPassword: Bool, password: String, completion: @escaping () -> Void) {
        db.collection("group").document(name).updateData([
            "isPassword": isPassword, "password": password
        ]) { err in
            if err == nil { completion() }
        }
    }

    func deleteUser(name: String, completion: @escaping () -> Void) {
        db.collection("users").document(name).delete { err in
            if err == nil { completion() }
        }
    }

    func deleteGroup(name: String, completion: @escaping () -> Void) {
        db.collection("group").document(name).delete { err in
            if err == nil { completion() }
        }
    }

    func deleteGroupTasks(groupName: String, completion: @escaping () -> Void) {
        db.collection("task").whereField("group", isEqualTo: groupName).getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents, !docs.isEmpty else { completion(); return }
            let batch = self.db.batch()
            docs.forEach { batch.deleteDocument($0.reference) }
            batch.commit { err in
                if err == nil { completion() }
            }
        }
    }

    func setGroupDeletionListener(name: String, onDeleted: @escaping () -> Void) -> ListenerRegistration {
        db.collection("group").document(name).addSnapshotListener { snapshot, _ in
            if snapshot?.exists == false {
                onDeleted()
            }
        }
    }
}
