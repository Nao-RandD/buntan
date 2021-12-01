//
//  SignupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/20.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var houseGroupTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!

    private let userDefaults = UserDefaults.standard
    private var groupPickerView: UIPickerView!
    /// FIXME - 仮置として追加
    private var groupList = [""]
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        if (userDefaults.object(forKey: "User") as? String) != nil {
            print("すでにログイン済み")
            DispatchQueue.main.async {
                self.nextScreen()
            }
            return
        }

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

    @IBAction func tappedSingupButton(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "必須項目の入力漏れ",
                      message: "ユーザー名を入力してください")
            return
        }
        guard let group = groupTextField.text, !group.isEmpty else {
            showAlert(title: "必須項目の入力漏れ",
                      message: "参加するグループを選択してください")
            return
        }

        userDefaults.set(name, forKey: "User")
        userDefaults.set(group, forKey: "Group")

        let data: [String: Any] = ["name": name, "group": group, "point": 0]
        db.collection("users").document(name).setData(data, merge: true)
        print("userDefaultsを更新")
        print("ユーザー名：\(name), グループ：\(group)としてSign Up完了")
        nextScreen()
    }
}

extension LoginViewController {
    private func nextScreen() {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: false, completion: nil)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message:  message,
                                      preferredStyle:  UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler: {
                                            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK - UIPickerViewDelegate

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        groupList.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let user = groupList[row]
        groupTextField.text = user
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        groupList[row]
    }
}
