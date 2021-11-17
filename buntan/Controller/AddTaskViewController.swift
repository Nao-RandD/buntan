//
//  AddTaskViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/19.
//

import UIKit
import RealmSwift

class AddTaskViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }

    @IBAction func tappedCreateButton(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        guard let point = pointTextField.text, !point.isEmpty else { return }

        let realm = try! Realm()
        guard let taskItem = setTaskItem(contents: realm.objects(TaskItem.self), name: name, point: point) else {
            print("書き込み失敗")
            return
        }

        try! realm.write {
            realm.add(taskItem)
            print("新しいリスト追加：\(name)")
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func setTaskItem(contents: Results<TaskItem>, name: String, point: String) -> TaskItem? {
        let taskItem = TaskItem()
        taskItem.name = name
        taskItem.taskId = contents.count + 1
        taskItem.point = Int(point) ?? 0

        return taskItem
    }
}
