//
//  HomeViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/08.
//

import UIKit
import Firebase
import RealmSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var indicator: UIActivityIndicatorView!
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private var selectTask: String = ""
    private var taskListener: ListenerRegistration?
    private var groupTasks : [GroupTask] = [GroupTask(group: "ハウス", name: "ほげ", point: 10)]

    struct GroupTask {
        var group: String
        var name: String
        var point: Int
    }

    override func viewWillAppear(_ animated: Bool) {
        settingTableView()
        setListener()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let group = self.userDefaults.object(forKey: "Group") as! String
        self.navigationItem.title = group
        settingTableView()
    }

    @IBAction func tappedSendButton(_ sender: Any) {
        let point: Int = {
            for task in groupTasks {
                if task.name == selectTask {
                    return task.point
                }
            }
            print("指定のポイントがありませんでした")
            return 0
        }()
        // Realmにデータを保存
        RealmManager.shared.writeTaskItem(task: selectTask, point: point)

        // Firestoreにデータを送信
        sendFirestore()
        showSuccessAlert()
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {}
}

extension HomeViewController {
    private func settingTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "TaskCell")
    }

    private func setListener() {
        self.taskListener = db.collection("task").addSnapshotListener { snapshot, e in
                if let snapshot = snapshot {
                    let group = self.userDefaults.object(forKey: "Group") as! String
                    let tasks = snapshot.documents.filter { $0.data()["group"] as! String == group }
                    self.groupTasks = tasks.map { task -> GroupTask in
                        let data = task.data()
                        return GroupTask(group: data["group"] as! String, name: data["name"] as! String, point: data["point"] as! Int)
                    }
                    print("中身は\(String(describing: self.groupTasks))")
                    self.tableView.reloadData()
                }
            }
    }

    private func sendFirestore() {
        let user = userDefaults.object(forKey: "User") as! String
        let group = userDefaults.object(forKey: "Group") as! String
        let point = RealmManager.shared.getTotalPoint()

        self.db.collection("users").document(user).setData([
            "name": user,
            "group": group,
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    private func reload() {
        tableView.reloadData()
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "タスクの送信完了",
                                      message:  "お疲れさまでした",
                                      preferredStyle:  UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler: {
                                            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK - UITableViewDelegate

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        cell.configure(taskName: groupTasks[indexPath.row].name,
                       point: groupTasks[indexPath.row].point)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("選択中のタスクは\(groupTasks[indexPath.row])")
        selectTask = groupTasks[indexPath.row].name
     }

    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            groupTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
