//
//  UserPointCell.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/14.
//

import Foundation
import UIKit

class UserPointCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var pointLabel: UILabel!

    func configure(user: String, point: Int) {
        nameLabel.text = user
        pointLabel.text = String(point)
    }
}
