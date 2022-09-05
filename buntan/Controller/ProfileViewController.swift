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
    private var groupList: [[GroupInfo: String]] = []
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

    @objc func tappedDone() {
        let name = groupList[selectGroupNum][GroupInfo.name]!
        let isPassword = groupList[selectGroupNum][GroupInfo.isPassword]!

        if isPassword == "true" {
            let password = groupList[selectGroupNum][GroupInfo.password]!
            showPasswordAlert(password: password,
                              completion: {
                self.showAlert(title: "グループ変更",
                                                    message: "\(name)にグループを変更すると、今のグループのタスクデータは削除されます。\nよろしいですか？",
                                                    positiveHandler: {
                                              self.groupTextField.text = name
                                              self.userDefaults.set(name, forKey: "Group")
                                              // 通知を送りたい箇所でこのように記述
                                              NotificationCenter.default.post(name: .notifyName, object: nil)
                                          },
                                                    negativeHandler: {
                    self.dismiss(animated: false)
                                          })
            })
        } else {
            showAlert(title: "グループ変更",
                      message: "\(name)にグループを変更すると、今のグループのタスクデータは削除されます。\nよろしいですか？",
                      positiveHandler: {
                self.groupTextField.text = name
                self.userDefaults.set(name, forKey: "Group")
                print("GroupのuserDefaultsを更新")
                // 通知を送りたい箇所でこのように記述
                NotificationCenter.default.post(name: .notifyName, object: nil)
            },
                      negativeHandler: {
                self.dismiss(animated: false)
            })
        }
    }

    @objc func tappedCancel() {
        self.view.endEditing(true)
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

    private func showPasswordAlert(password: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "パスワード入力"
        alert.message = "選択したグループにはパスワードが設定されています。グループオーナーからパスワードを共有してもらってください。"
        alert.textFields?.first?.placeholder = "パスワード"
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.addTarget(self, action: #selector(textFieldDidChange), for: .allEditingEvents)

        //追加ボタン
        alert.addAction(
            UIAlertAction(
                title: "決定",
                style: .default,
                handler: { _ -> Void in
                    if self.inputPassword == password {
                        print("パスワード一致")
                        alert.dismiss(animated: false)
                        completion()
                    } else {
                        print("パスワード不一致")
                        alert.dismiss(animated: false)
                    }
                })
        )

        //キャンセルボタン
        alert.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: .cancel,
                handler: {(action) -> Void in
                    alert.dismiss(animated: false)
                })
        )
        present(alert, animated: true, completion: nil)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            inputPassword = text
        }
    }

    private func showAlert(title: String,
                           message: String,
                           positiveHandler: @escaping () -> Void,
                           negativeHandler: @escaping
    () -> Void) {
        let alert = UIAlertController(title: title,
                                      message:  message,
                                      preferredStyle:  UIAlertController.Style.alert)
        let positiveAction = UIAlertAction(title: "はい",
                                          style: UIAlertAction.Style.default,
                                          handler: {
            (action: UIAlertAction!) -> Void in
            positiveHandler()
            self.view.endEditing(true)
        })
        let negativeAction = UIAlertAction(title: "いいえ",
                                          style: UIAlertAction.Style.default,
                                          handler: {
            (action: UIAlertAction!) -> Void in
            negativeHandler()
        })
        alert.addAction(positiveAction)
        alert.addAction(negativeAction)
        present(alert, animated: true, completion: nil)
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
