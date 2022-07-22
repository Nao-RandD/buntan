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

    func sendDoneTask(user: String, group: String, point: Int) {
        db.collection("users").document(user).setData([
            "name": user,
            "group": group,
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
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
