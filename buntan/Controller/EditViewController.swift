//
//  EditViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/07/25.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!

    private var placeName: String = ""
    private var placePoint: Int = 0
    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.text = placeName
        pointTextField.text = "\(placePoint)"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func tappedSaveButton(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        guard let point = pointTextField.text, !point.isEmpty else { return }
        let group = self.userDefaults.object(forKey: "Group") as! String

        let beforeTask = GroupTask(group: group, name: placeName, point: placePoint)
        let afterTask = GroupTask(group: group, name: name, point: Int(point)!)

        sendFirestore(before: beforeTask, after: afterTask)
    }

    /// 変更前のタスクをセットする
    func setTaskItem(name: String, point: Int) {
        placeName = name
        placePoint = point
    }
}

// MARK: - Private Func -

extension EditViewController {
    private func sendFirestore(before beforeTask: GroupTask, after afterTask: GroupTask) {
        // afterTaskの内容にFirebaseを修正する
        FirebaseManager.shared.editDocument(before: beforeTask,
                                            after: afterTask,
                                            completion: {
            DispatchQueue.main.async {
                self.nameTextField.text = ""
                self.pointTextField.text = ""
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
