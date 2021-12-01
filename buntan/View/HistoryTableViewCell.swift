//
//  HistoryTableViewCell.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/26.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskNumberLabel: UILabel!

    func configure(taskName: String, taskNum: Int) {
        taskNameLabel.text = taskName
        taskNumberLabel.text = "\(taskNum)pt"
    }
}
