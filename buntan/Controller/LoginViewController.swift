//
//  LoginViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/12/13.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        if userDefaults.object(forKey: "isLogin") as? Bool ?? false {
            print("すでにログイン済み")
            DispatchQueue.main.async {
                self.nextScreen()
            }
            return
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func tappedSignInButton(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if (result?.user) != nil {
                self.userDefaults.set(true, forKey: "isLogin")
                self.nextScreen()
            }
            self.showErrorIfNeeded(error)
        }
    }
}

// MARK - Private Function -

extension LoginViewController {
    private func nextScreen() {
//        self.userDefaults.set(name, forKey: "User")

        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartAppViewController") as! StartAppViewController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: false, completion: nil)
    }

    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        // エラーがなければ何もしません
        guard let error = errorOrNil else { return }

        let message = errorMessage(of: error) // エラーメッセージを取得
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }

        switch errorCode {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        // これは一例です。必要に応じて増減させてください
        default: break
        }
        return message
    }
}
