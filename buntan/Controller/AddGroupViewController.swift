//
//  AddGroupViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/01/28.
//

import UIKit
import XLPagerTabStrip

class AddGroupViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var groupNameTextField: UITextField!

    var itemInfo: IndicatorInfo = "Group"

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    @IBAction func tappedCreateButton(_ sender: Any) {
        guard let name = groupNameTextField.text, !name.isEmpty else { return }

        sendFirestore(name: name)
    }
}

extension AddGroupViewController {
    private func sendFirestore(name: String) {
        FirebaseManager.shared.addGroup(name: name, completion: {
            DispatchQueue.main.async {
                self.groupNameTextField.text = ""
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
