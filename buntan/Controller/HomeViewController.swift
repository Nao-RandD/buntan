//
//  HomeViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/08.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskAddButton: UIBarButtonItem!

    private var indicator: UIActivityIndicatorView!
    private let userDefaults = UserDefaults.standard
    private var selectTask: String = ""
    private var groupTasks : [GroupTask] = [GroupTask(group: "ハウス", name: "ほげ", point: 10)]

    struct GroupTask {
        var group: String
        var name: String
        var point: Int
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            // disable UITab bar transparent
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }

        /// ホームのグループ名を取得してNavigation Barに設定
        let group = self.userDefaults.object(forKey: "Group") as! String
        self.navigationItem.title = group
        settingTableView()

        /// NotificationCenterを登録
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadScreen),
                                               name: .notifyName,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        settingTableView()
        setListener()
    }

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            print("1秒後の処理")
//            self.showTutorial()
            let isShowTutorial = self.userDefaults.object(forKey: "isShowTutorial") as? Bool ?? false
            if !isShowTutorial {
                self.showTutorial()
            }
        }
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

        FirebaseManager.shared.getDocument()
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {}
}

// MARK: - Private Func

extension HomeViewController {
    @objc func reloadScreen(notification: Notification?) {
        print("\(String(describing: notification))からの通知でグループが変更されたのでリロード")
        let group = self.userDefaults.object(forKey: "Group") as! String
        self.navigationItem.title = group
        RealmManager.shared.deleteAllTaskItem()
        setListener()
        reload()
    }

    /// 吹き出しメニューを作成する
    private func makeContextMenu(index: Int) -> UIMenu {
        let edit = UIAction(title: "編集", image: UIImage(systemName: "figure.wave")) { action in
            print("編集")
            let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! AddTaskViewController
//            editVC.configure(type: .edit(index: index))
            self.present(editVC, animated: true, completion: nil)
        }

        let delete = UIAction(title: "削除", image: UIImage(systemName: "bag")) { action in
            print("削除")
            // Firebaseのタスクを削除するようにする

        }

        return UIMenu(title: "Menu", children: [edit, delete])
    }

    private func settingTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "TaskCell")
    }

    private func setListener() {
        FirebaseManager.shared.setListener(completion: { snapshot in
            let group = self.userDefaults.object(forKey: "Group") as! String
            let tasks = snapshot.documents.filter { $0.data()["group"] as! String == group }
            self.groupTasks = tasks.map { task -> GroupTask in
                let data = task.data()
                let task = GroupTask(group: data["group"] as! String, name: data["name"] as! String, point: data["point"] as! Int)
                return task
            }
            print("中身は\(String(describing: self.groupTasks))")
            self.reload()
        })
    }

    private func sendFirestore() {
        let user = userDefaults.object(forKey: "User") as! String
        let group = userDefaults.object(forKey: "Group") as! String
        let point = RealmManager.shared.getTotalPoint()

        FirebaseManager.shared.sendDoneTask(user: user, group: group, point: point)
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

    private func showTutorial() {
        guard let frame = self.navigationController?.navigationBar.frame else { return }
        print(dump(frame))

        let addButtonview = UIView()
        addButtonview.frame = frame

        print("チュートリアルを表示")
        let vc = TutorialViewController()
        vc.showTutorial(from: self.navigationController!, target: addButtonview)
    }
}

// MARK: - UITableViewDelegate

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

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { suggestedActions in
            return self.makeContextMenu(index: index)
        })
    }

}

// MARK: - Notification Center Extention
extension Notification.Name {
    static let notifyName = Notification.Name("notifyName")
}
