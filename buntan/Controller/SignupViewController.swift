//
//  SignupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/20.
//

import UIKit

class SignupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }

    @IBAction func tappedSingupButton(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: false, completion: nil)
    }
}
