//
//  FirebaseManager.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/10/30.
//

import Firebase

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
            completion()
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
}
