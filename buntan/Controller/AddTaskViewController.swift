//
//  AddTaskViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/19.
//

import UIKit
import Firebase
import RealmSwift

class AddTaskViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!

    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }

    @IBAction func tappedCreateButton(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        guard let point = pointTextField.text, !point.isEmpty else { return }

        sendFirestore(name: name, point: Int(point) ?? 0)
    }

    private func setTaskItem(contents: Results<TaskItem>, name: String, point: String) -> TaskItem? {
        let taskItem = TaskItem()
        taskItem.name = name
//        taskItem.taskId = contents.count + 1
        taskItem.point = Int(point) ?? 0

        return taskItem
    }
}

// MARK - Private Func -

extension AddTaskViewController {
    private func sendFirestore(name: String, point: Int) {
        let group = self.userDefaults.object(forKey: "Group") as! String

        db.collection("task").addDocument(data: [
            "group": group,
            "name": name,
            "point": point
        ]) { err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.nameTextField.text = ""
                    self.pointTextField.text = ""
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
