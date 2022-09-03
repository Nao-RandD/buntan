//
//  ProfileViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/22.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!

    private let userDefaults = UserDefaults.standard
    private var groupList = [""]
    private let db = Firestore.firestore()
    private var groupPickerView: UIPickerView!
    private var selectGroupNum: Int = 0
    private var inputPassword: String = ""

    enum GroupInfo: String {
        case name, isPassword, password
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ユーザー情報"
        nameTextField.text = userDefaults.object(forKey: "User") as? String
        groupTextField.text = userDefaults.object(forKey: "Group") as? String
        nameTextField.delegate = self

        // groupPickerViewを設定
        groupPickerView = UIPickerView()
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        groupTextField.inputView = groupPickerView

        let collectionReference = db.collection("group")
        collectionReference.getDocuments { (_snapshot, _error) in
            if let error = _error {
                print(error.localizedDescription)
                return
            }

            let datas = _snapshot!.documents.compactMap { $0.data() }
            let groups = datas.map {
                $0["name"]
            } as? [String]
            self.groupList = groups ?? ["ハウス", "自宅"]
            print(self.groupList)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Keyを指定して保存
        userDefaults.set(textField.text, forKey: "User")
        print("UserのuserDefaultsを更新")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

// MARK: - UIPickerViewDelegate

extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        groupList.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectGroupNum = row
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let isPassword = groupList[row][GroupInfo.isPassword]
        if isPassword == "true" {
            return "🔓　\(groupList[row][GroupInfo.name]!)"
        } else {
            return groupList[row][GroupInfo.name]
        }
    }
}
