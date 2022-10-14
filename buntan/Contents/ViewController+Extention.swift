//
//  ViewController+Extention.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/09/06.
//

import UIKit

extension UIViewController {
    enum AlertType {
        case normal, twoChoice
    }



    /// はい / いいえの選択肢を持ったアラート
    /// - Parameters:
    ///   - title: アラートのタイトル
    ///   - message: アラートの本文
    ///   - positiveHandler: はいを押した場合のコールバック
    ///   - negativeHandler: いいえを押した場合のコールバック
    func showAlert(title: String,
                   message: String,
                   positiveHandler: @escaping () -> Void,
                   negativeHandler: @escaping () -> Void) {
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


    func showAlert(title: String,
                   message: String,
                   completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message:  message,
                                      preferredStyle:  UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler: {
                                            (action: UIAlertAction!) -> Void in
            if completion != nil { completion!() }
        })
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}
