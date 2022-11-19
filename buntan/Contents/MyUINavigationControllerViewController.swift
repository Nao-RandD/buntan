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
        // This will change the navigation bar background color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = #colorLiteral(red: 1, green: 0.6067512035, blue: 0, alpha: 1)

        // This will alter the navigation bar title appearance
        let titleAttribute = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white] //alter to fit your needs
        appearance.titleTextAttributes = titleAttribute

        navigationBar.tintColor = .white
        navigationBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
