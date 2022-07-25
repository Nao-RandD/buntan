//
//  AddTaskViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/19.
//

import UIKit
import RealmSwift
import XLPagerTabStrip

class AddTaskViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!

    private let userDefaults = UserDefaults.standard

    var itemInfo: IndicatorInfo = "Task"

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

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

// MARK: - Private Func -

extension AddTaskViewController {
    private func setTaskItem(contents: Results<TaskItem>, name: String, point: String) -> TaskItem? {
        let taskItem = TaskItem()
        taskItem.name = name
        taskItem.point = Int(point) ?? 0

        return taskItem
    }

    private func sendFirestore(name: String, point: Int) {
        let group = self.userDefaults.object(forKey: "Group") as! String

        FirebaseManager.shared.addTask(name: name,
                                            group: group,
                                            point: point,
                                            completion: {
            DispatchQueue.main.async {
                self.nameTextField.text = ""
                self.pointTextField.text = ""
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
