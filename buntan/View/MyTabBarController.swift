//
//  MyTabBarController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/11/19.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        let appearance = UITabBarAppearance()
        appearance.backgroundColor =  .white

        UITabBar.appearance().tintColor = .red
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

extension MyTabBarController: UITabBarControllerDelegate  {
// /// TabBarが切り替わるタイミングでディゾルブのアニメーションを適用する
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
//          return false // Make sure you want this as false
//        }
//
//        if fromView != toView {
//          UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
//        }
//
//        return true
//    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item),
              let customTabBar = tabBar as? CustomTabBar,
              let imageView = customTabBar.barItemImage(index: index) else {
            return
        }
        iconBounceAnimation(view: imageView)
    }
    
    func iconBounceAnimation(view: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            view.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }, completion: nil)
    }
}

class CustomTabBar: UITabBar {
    /// indexを受け取り、タブのUIImageViewを返却する
    func barItemImage(index: Int) -> UIImageView? {
        let view = subviews[index + 1]
        return view.recursiveSubviews.compactMap { $0 as? UIImageView }
        .first
    }
}

extension UIView {
    // 再起的にsubviewsを取得
    var recursiveSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.recursiveSubviews }
    }
}
