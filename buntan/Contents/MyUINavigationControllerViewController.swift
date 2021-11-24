//
//  MyUINavigationControllerViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/15.
//

import UIKit

class MyUINavigationControllerViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        //　ナビゲーションバーの背景色
        navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.6067512035, blue: 0, alpha: 1) // その他UIColor.white等好きな背景色
        // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
        navigationBar.tintColor = .white
        // ナビゲーションバーのテキストを変更する
        navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.white
        ]

        if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = #colorLiteral(red: 1, green: 0.6067512035, blue: 0, alpha: 1)
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
