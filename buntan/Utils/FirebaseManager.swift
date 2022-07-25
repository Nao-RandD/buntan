//
//  FirebaseManager.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/10/30.
//

import Firebase

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

    func addGroup(name: String, completion: @escaping () -> Void) {
        db.collection("group").document(name).setData([
            "name": name,
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
}
