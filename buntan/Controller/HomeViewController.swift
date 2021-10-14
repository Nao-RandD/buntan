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
    private var _taskList: [[String]] = [["", ""]]
    private var realm: Realm!
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
        // Do any additional setup after loading the view.

        getTaskList()
        settingTableView()
    }

    @IBAction func tappedSendButton(_ sender: Any) {
        showIndicator()

        /// TODO - 
        // Realmにデータを保存


        // Firestoreにデータを送信
        sendFirestore()
        self.indicator.stopAnimating()
//        self.showDoneImage()
        sleep(1)
        showSuccessAlert()
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {}
}

extension HomeViewController {
    private func settingTableView() {
        indicator = UIActivityIndicatorView()
        view.addSubview(indicator)

//        realm = try! Realm()
//        taskList = realm.objects(TaskItem.self)
//        token = taskList.observe { [weak self] _ in
//          self?.reload()
//        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "TaskCell")
    }

    private func setListener() {
        self.taskListener = db.collection( "task" ).addSnapshotListener { snapshot, e in
                if let snapshot = snapshot {

                    self.groupTasks = snapshot.documents.map { task -> GroupTask in
                        let data = task.data()
                        return GroupTask(group: data["group"] as! String, name: data["name"] as! String, point: data["point"] as! Int)
                    }
                    print("中身は\(self.groupTasks)")
                    self.tableView.reloadData()
                }
            }
    }

    private func saveToRealm() {

    }

    private func getTaskList() {
        let group = userDefaults.object(forKey: "Group") as! String
        let taskCollection = db.collection("task")
        taskCollection.getDocuments { (_snapshot, _error) in
            if let error = _error {
                print(error.localizedDescription)
                return
            }
        }
    }

    private func setTaskItem(contents: Results<TaskItem>, user: String, point: Int) -> TaskItem {
        let task = TaskItem()
        task.taskId = contents.count + 1
        task.name = user
        task.point = point

        return task
    }


    private func sendFirestore() {
        let user = userDefaults.object(forKey: "User") as! String
        let gourp = userDefaults.object(forKey: "Group") as! String
        let point = getTotalPoint()
        let data: [String: Any] = ["name": user, "group": gourp, "point": point]

        self.db.collection("task").addDocument(data: data)
    }

    private func getTotalPoint() -> Int {
        var total = 0
//        for task in taskList {
//            total += task.point
//        }
        return total
    }

    private func reload() {
        tableView.reloadData()
    }

    private func showDoneImage() {
        let image = UIImage(named: "Done")
        let imageView = UIImageView(image: image)

        imageView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        view.addSubview(imageView)
    }

    private func showIndicator() {
        guard let indicator = indicator else {
            return
        }
        indicator.center = view.center
        indicator.style = .whiteLarge
        indicator.color = .darkGray

        indicator.startAnimating()
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
