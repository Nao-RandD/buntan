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
    private var taskList: [String: Int] = ["タスク": 0]
    private var token: NotificationToken?
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private var selectTask: String = ""
    private var taskListener: ListenerRegistration?
    private var groupTasks : [GroupTask]? = nil

    struct GroupTask {
        var group: String
        var name: String
        var point: Int
    }

    override func viewWillAppear(_ animated: Bool) {
        getTaskList()
        settingTableView()
        setListener()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let group = self.userDefaults.object(forKey: "Group") as! String
        self.navigationItem.title = group
        getTaskList()
        settingTableView()
    }

    @IBAction func tappedSendButton(_ sender: Any) {
        guard let point = groupTasks?[0].point else {
            print("ポイント取得に失敗")
            return
        }
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

    private func getTaskList() {
//        let group = userDefaults.object(forKey: "Group") as! String
        let taskCollection = db.collection("task")
        taskCollection.getDocuments { (_snapshot, _error) in
            if let error = _error {
                print(error.localizedDescription)
                return
            }
        }
    }

    private func sendFirestore() {
        let user = userDefaults.object(forKey: "User") as! String
        let group = userDefaults.object(forKey: "Group") as! String
        let point = RealmManager.shared.getTotalPoint()
//        let data: [String: Any] = ["name": user, "group": group, "point": point]

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
        guard let groupTasks = groupTasks else { return 0 }
        return groupTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        guard let groupTasks = groupTasks else { return cell }
        cell.configure(taskName: groupTasks[indexPath.row].name,
                       point: groupTasks[indexPath.row].point)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let groupTasks = groupTasks else { return }
        print("選択中のタスクは\(groupTasks[indexPath.row])")
        selectTask = groupTasks[indexPath.row].name
     }
}




//private func showDoneImage() {
//    let image = UIImage(named: "Done")
//    let imageView = UIImageView(image: image)
//
//    imageView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
//    view.addSubview(imageView)
//}
//
//private func showIndicator() {
//    guard let indicator = indicator else {
//        return
//    }
//    indicator.center = view.center
//    indicator.style = .whiteLarge
//    indicator.color = .darkGray
//    indicator.startAnimating()
//}
