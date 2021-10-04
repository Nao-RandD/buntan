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

    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.

        getTaskList()
        settingTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        getTaskList()
        settingTableView()
    }

    @IBAction func tappedSendButton(_ sender: Any) {
        showIndicator()

        // TableViewで選択されているタスクを取得
        let taskCollection = db.collection("group")
        taskCollection.getDocuments { (_snapshot, _error) in
            if let error = _error {
                print(error.localizedDescription)
                return
            }

            let datas = _snapshot!.documents.compactMap { $0.data() }
            let groups = datas.map {
                $0["task"]
            } as? [String: Int]
            self.taskList = groups ?? ["タスク": 0]
        }

        // Realmにデータを保存


        // Firestoreにデータを送信
        sendFirestore()
        self.indicator.stopAnimating()
//        self.showDoneImage()
        sleep(1)
        showSuccessAlert()
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {}

//    func hideIndicator(){
//        // viewにローディング画面が出ていれば閉じる
//        if let viewWithTag = self.view.viewWithTag(100100) {
//            viewWithTag.removeFromSuperview()
//        }
//    }
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

    private func saveToRealm() {

    }

    private func getTaskList() {
        let group = userDefaults.object(forKey: "Group") as! String
        let taskCollection = db.collection("group").document(group)
        taskCollection.getDocument { (_snapshot, _error) in
            if let error = _error {
                print(error.localizedDescription)
                return
            }

            if let document = _snapshot, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")

                guard let data = document.data() as? [String: Any] else {
                    print("データを取得できませんでした")
                    return
                }
                print("Documentのtaskは\(data)")
            } else {
                print("Document does not exist")
            }
//
//            let datas = _snapshot!.documents.compactMap { $0.data() }
//            print(datas)
//            let groups = datas.map {
//                print("taskの中身は\($0["task"])")
//                $0["task"]
//            } as? [String: Int]
//            print(groups)
//            self.taskList = groups ?? ["タスク": 0]
        }

        for (key, value) in taskList {
            let _value = String(value)
            _taskList.append([key, _value])
        }
        print(_taskList)
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

        self.db.collection("users").document(user).setData(data, merge: true)
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
//        guard let taskList = taskList else {
//            return 0
//        }
        return taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell

        // カスタムセルにRealmの情報を反映
        cell.configure(taskName: _taskList[indexPath.row][0],
        point: Int(_taskList[indexPath.row][1]) ?? 0)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("選択中のタスクは\(taskList[indexPath.row])")
//        selectTask = taskList[indexPath.row].name
     }
}
