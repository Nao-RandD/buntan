//
//  HistoryViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/26.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {

    private var taskList: Results<TaskItem>!
//    private var token: NotificationToken?
    private var selectTask: String = ""

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        settingTableView()
    }
}

extension HistoryViewController {
    private func settingTableView() {
        taskList = RealmManager.shared.getTaskInRealm()
//        token = taskList.observe { [weak self] _ in
//          self?.reload()
//        }
        self.navigationItem.title = "タスク履歴"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "HistoryCell")
    }

    private func reload() {
        tableView.reloadData()
    }

    private func deleteTaskItem(at index: Int) {
        RealmManager.shared.deleteTaskItem(item: taskList[index])
        taskList = RealmManager.shared.getTaskInRealm()
        tableView.reloadData()
    }
}

// MARK - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let taskList = taskList else {
            return 0
        }
        return taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        // カスタムセルにRealmの情報を反映
        cell.configure(taskName: taskList[indexPath.row].name,
                       taskNum: taskList[indexPath.row].point)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("選択中のタスクは\(taskList[indexPath.row])")
        selectTask = taskList[indexPath.row].name
     }

    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            deleteTaskItem(at: indexPath.row)
//            groupTasks.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
