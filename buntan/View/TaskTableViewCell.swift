//
//  TaskTableViewCell.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/16.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskPointLabel: UILabel!

    func configure(taskName: String, point: Int) {
        taskNameLabel.text = taskName
        taskPointLabel.text = "\(point) pt"
    }
}
