//
//  MenuViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/18.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!

    private let userDefaults = UserDefaults.standard

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メニューの位置を取得する
        let menuPos = self.menuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅の分だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
        },
            completion: { bool in
        })
        userNameLabel.text = userDefaults.object(forKey: "User") as? String
        let pointTotal = RealmManager.shared.getTotalPoint()
        pointLabel.text = "\(pointTotal) pt"
    }

    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {
        userNameLabel.text = userDefaults.object(forKey: "User") as? String
    }
}
