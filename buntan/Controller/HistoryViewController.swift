//
//  TaskHistoryViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/26.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {
    private var taskList: Results<TaskItem>!
    private var selectTask: String = ""

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "TaskHistoryTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "TaskCell")
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let taskList = taskList else {
            return 0
        }
        return taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell

        // カスタムセルにRealmの情報を反映
        cell.configure(taskName: taskList[indexPath.row].name,
                       point: taskList[indexPath.row].point)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("選択中のタスクは\(taskList[indexPath.row])")
        selectTask = taskList[indexPath.row].name
     }
}
