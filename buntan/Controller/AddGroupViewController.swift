//
//  AddGroupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/01/28.
//

import UIKit
import XLPagerTabStrip

class AddGroupViewController: UIViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "Group"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
