//
//  ProfileViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/22.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var groupLabel: UILabel!

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ユーザー情報"
        nameTextField.text = userDefaults.object(forKey: "User") as? String
        groupLabel.text = userDefaults.object(forKey: "Group") as? String
        nameTextField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
}

// MARK - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Keyを指定して保存
        userDefaults.set(textField.text, forKey: "User")
        print("userDefaultsを更新")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

