//
//  SignupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/11/16.
//

import Firebase
import UIKit

class SignupViewController: UIViewController {
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction private func didTapSignUpButton() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let name = nameTextField.text ?? ""

        signUp(email: email, password: password, name: name)
//        signUpMail(email: email)
    }

    private func signUpMail(email: String) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://buntan.page.link")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        Auth.auth().sendSignInLink(toEmail: email,
                                   actionCodeSettings: actionCodeSettings) { error in
          // ...
            if let error = error {
//              self.showDialog(error.localizedDescription)
              return
            }
            // The link was successfully sent. Inform the user.
            // Save the email locally so you don't need to ask the user for it again
            // if they open the link on the same device.
            UserDefaults.standard.set(email, forKey: "Email")
//            self.showDialog("Check your email for link")
            // ...
        }
    }
}

// MARK - Private Function -

extension SignupViewController {
    private func signUp(email: String, password: String, name: String) {
        print("メール：\(email)、パスワード\(password)、ユーザー名\(name)を登録")
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            print("\(String(describing: result))")
            guard let self = self else { return }
            if let user = result?.user {
                print("メールアドレス登録完了")
//                self.sendEmailVerification(to: user, name: name)
                self.updateDisplayName(name, of: user)
            }
            self.showError(error)
        }
    }

    private func updateDisplayName(_ name: String, of user: User) {
        print("表示名の更新")
        let request = user.createProfileChangeRequest()
        request.displayName = name
        request.commitChanges() { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                print("ユーザー名登録完了")
                self.sendEmailVerification(to: user, name: name)
            }
            self.showError(error)
        }
    }

    private func sendEmailVerification(to user: User, name: String) {
        user.sendEmailVerification() { [weak self] error in
            print("ここは呼ばれている")
            guard let self = self else { return }
            print("ここも呼ばれている")
            print("エラーは\(error?.localizedDescription)")
            if error == nil {
                print("アクティベート含めた登録完了")
                DispatchQueue.main.async {
                    self.showDialog("メールアプリから認証を完了してください", user: name)
                }
            }
            self.showError(error)
        }
    }

    private func showDialog(_ message: String, user user: String) {
        let alert = UIAlertController(title: "メール認証", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: {
                                              (action: UIAlertAction!) -> Void in
            self.nextScreen(name: user)
                                          }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showError(_ errorOrNil: Error?) {
        // エラーがなければ何もしません
        guard errorOrNil != nil else { return }
        print("エラー内容は\(errorOrNil)")

        let message = errorOrNil?.localizedDescription
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func nextScreen(name: String) {
        self.userDefaults.set(name, forKey: "User")

        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! StartAppViewController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: false, completion: nil)
    }
}
