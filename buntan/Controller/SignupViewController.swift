//
//  SignupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/11/16.
//

import Firebase
import UIKit
import RxSwift
import PKHUD

class SignupViewController: UIViewController {
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!

    private let disposeBag = DisposeBag()

    private var viewModel: RegiserViewModel?

    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = RegiserViewModel()

        passwordTextField.isSecureTextEntry = true

        setupBinding()

        if userDefaults.object(forKey: "isSignup") as? Bool ?? false ||
            userDefaults.object(forKey: "isLogin") as? Bool ?? false {
            print("すでにサインアップ済み")
            DispatchQueue.main.async {
                self.nextScreen()
            }
            return
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

//    @IBAction private func didTapSignUpButton() {
//        let email = emailTextField.text ?? ""
//        let password = passwordTextField.text ?? ""
//        let name = nameTextField.text ?? ""
//
//        signUp(email: email, password: password, name: name)
//    }

    // ログイン画面への繊維
    @IBAction func didTapToLoginButton(_ sender: Any) {
        DispatchQueue.main.async {
            self.nextScreen()
        }
    }
}

// MARK - Private Function -

extension SignupViewController {
    private func setupBinding() {
        nameTextField.rx.text
            .asDriver()
            .drive { [weak self] text in
                self?.viewModel!.nameTextInput.onNext(text ?? "")
            }
            .disposed(by: disposeBag)

        emailTextField.rx.text
            .asDriver()
            .drive { [weak self] text in
                self?.viewModel!.emailTextInput.onNext(text ?? "")
            }
            .disposed(by: disposeBag)

        passwordTextField.rx.text
            .asDriver()
            .drive { [weak self] text in
                self?.viewModel!.passwordTextInput.onNext(text ?? "")
            }
            .disposed(by: disposeBag)

        signUpButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                // 登録時の処理
                self?.createUser()
            }
            .disposed(by: disposeBag)

        // viewModelのbinding
        viewModel?.validRegisterDriver
            .drive { validAll in
                self.signUpButton.isEnabled = validAll
                self.signUpButton.backgroundColor = validAll ? .rgb(red: 227, green: 48, blue: 78) : .init(white: 0.7, alpha: 1)
            }
            .disposed(by: disposeBag)
    }

    private func createUser() {
        let email = emailTextField.text
        let password = passwordTextField.text
        let name = nameTextField.text

        HUD.show(.progress)
        FirebaseManager.createUserToFireAuth(email: email, password: password, name: name) { success in
            HUD.hide()
            if success {
                print("処理が完了")
                self.dismiss(animated: true)

                self.showAlert(title: "登録成功", message: "ユーザーの登録が完了しました") {
                    self.nextScreen()
                }
            } else {
                self.showAlert(title: "無効な情報が含まれていました", message: "ユーザー名・パスワードは5文字以上か？メールアドレスは有効なものか？")
            }
        }
    }
    // 次の画面に遷移する
    private func nextScreen() {
        self.userDefaults.set(true, forKey: "isSignup")

        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: false, completion: nil)
    }
}
