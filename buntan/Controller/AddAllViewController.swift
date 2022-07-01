//
//  AddAllViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/01/28.
//

import UIKit
import XLPagerTabStrip

class AddAllViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = #colorLiteral(red: 1, green: 0.6067512035, blue: 0, alpha: 1)
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = UIColor(red: 254/255, green: 0, blue: 124/255, alpha: 1)
        settings.style.buttonBarMinimumLineSpacing = 5.0

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else {
                newCell?.label.textColor = .white
                newCell?.label.font = UIFont.systemFont(ofSize: 20)
                oldCell?.label.font = UIFont.boldSystemFont(ofSize: 30)
                return
            }
            oldCell?.label.textColor = .white
            oldCell?.label.font = UIFont.systemFont(ofSize: 20)
            newCell?.label.font = UIFont.boldSystemFont(ofSize: 30)
        }

    }
    

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        let taskVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Task")
        let groupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Group")
        let childViewControllers:[UIViewController] = [taskVC, groupVC]
        return childViewControllers
    }
}
