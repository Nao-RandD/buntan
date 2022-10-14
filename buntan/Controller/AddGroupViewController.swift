//
//  AddGroupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/01/28.
//

import UIKit
import XLPagerTabStrip

class AddGroupViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var passwordSwitch: UISwitch!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!

    var itemInfo: IndicatorInfo = "Group"

    // 入力状態を管理する
    enum ValidInput {
        case valid(String)
        case validWithPassword(String, String)
        case noGroupName
        case noPassword
        case invalidPassword

        var alertTitle: String {
            switch self {
            case .valid, .validWithPassword:
                return ""
            case .noGroupName:
                return "グループ名入力なし"
            case .noPassword:
                return "パスワード入力なし"
            case .invalidPassword:
                return "パスワードフォーマットエラー"
            }
        }

        var alertMessage: String {
            switch self {
            case .valid, .validWithPassword:
                return ""
            case .noGroupName:
                return "グループ名を入力してください"
            case .noPassword:
                return "パスワードを入力してください（半角英数字5文字以上）"
            case .invalidPassword:
                return "パスワードは半角英数字5文字以上で設定してください）"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    @IBAction func tappedCreateButton(_ sender: Any) {
        let result = validInput()

        switch result {
        case .valid(let name):
            sendFirestore(name: name, password: nil)
        case .validWithPassword(let name, let password):
            sendFirestore(name: name, password: password)
        case .noGroupName, .noPassword, .invalidPassword:
            showAlert(title: result.alertTitle, message: result.alertMessage)
        }
    }

    @IBAction func tappedPasswordSwitch(_ sender: UISwitch) {
        let status = sender.isOn

        // パスワード設定がONの場合にはisHiddenをfalse
        passwordLabel.isHidden = !status
        passwordTextField.isHidden = !status
        passwordTextField.text = ""
    }
}

extension AddGroupViewController {
    private func sendFirestore(name: String, password: String?) {
        FirebaseManager.shared.addGroup(name: name, password: password, completion: {
            self.groupNameTextField.text = ""
            self.dismiss(animated: true, completion: nil)
        })
    }

    private func validInput() -> ValidInput {
        // グループ名の入力がない場合を考慮
        guard let name = groupNameTextField.text, !name.isEmpty else {
            return ValidInput.noGroupName
        }

        let switchStatus = passwordSwitch.isOn
        guard switchStatus else { return ValidInput.valid(name) }

        // パスワードの入力がない場合を考慮
        guard let password = passwordTextField.text, !password.isEmpty else {
            return ValidInput.noPassword
        }

        // 5文字以上, すべて半角英数字
        if password.count >= 5, password.isAlphanumeric() {
            return ValidInput.validWithPassword(name, password)
        } else {
            return ValidInput.invalidPassword
        }
    }
}


extension String {
    /// 文字が半角英数字のみか判定
    /// - Returns: true：半角英数字のみ、false：半角英数字以外が含まれる
    fileprivate func isAlphanumeric() -> Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
