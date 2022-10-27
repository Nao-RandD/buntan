//
//  HomeViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/08.
//

import UIKit
import FirebaseAuth
import RealmSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskAddButton: UIBarButtonItem!

    private var indicator: UIActivityIndicatorView!
    private let userDefaults = UserDefaults.standard
    private var selectIndex: Int?  = nil
    private var groupTasks : [GroupTask] = [GroupTask(group: "ハウス", name: "ほげ", point: 10)]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeViewControlelr\(#function)")

        if #available(iOS 15.0, *) {
            // disable UITab bar transparent
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }

        guard let uid = Auth.auth().currentUser?.uid else { return }
    
        /// NotificationCenterを登録
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadScreen),
                                               name: .notifyName,
                                               object: nil)

        settingTableView()
        setListener()

        /// ホームのグループ名を取得してNavigation Barに設定
        let group = self.userDefaults.object(forKey: "Group") as! String
        self.navigationItem.title = group
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("HomeViewControlelr\(#function)")

        // FirebaseAuthにuidがなければサインアップ画面を表示
        if Auth.auth().currentUser?.uid == nil {
            let signupViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            signupViewController.modalPresentationStyle = .fullScreen
            self.present(signupViewController, animated: false, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        print("HomeViewControlelr\(#function)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let isShowTutorial = self.userDefaults.object(forKey: "isShowTutorial") as? Bool ?? false
            if !isShowTutorial {
                self.showTutorial()
            }
        }
    }

    @IBAction func tappedSendButton(_ sender: Any) {
        guard let index = selectIndex else {
            showAlert(title: "選択エラー", message: "タスクを選択してください")
            return
        }
        let point: Int = groupTasks[index].point
        let task: String = groupTasks[index].name
        // Realmにデータを保存
        RealmManager.shared.writeTaskItem(task: task, point: point)

        // Firestoreにデータを送信
        sendFirestore()

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
            let name = self.groupTasks[index].name
            let point = self.groupTasks[index].point
            let editVC = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
            editVC.setTaskItem(name: name, point: point)
            self.present(editVC, animated: true, completion: nil)
        }

        let delete = UIAction(title: "削除", image: UIImage(systemName: "bag")) { action in
            print("削除")
            let name = self.groupTasks[index].name
            let point = self.groupTasks[index].point
            let group = self.userDefaults.object(forKey: "Group") as! String
            let task = GroupTask(group: group, name: name, point: point)
            // Firebaseのタスクを削除
            FirebaseManager.shared.deleteDocument(target: task,
                                                  completion: {

                DispatchQueue.main.async {
                    self.showAlert(title: "削除", message: "タスクの削除に成功しました")
                }
            })
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
        let name = userDefaults.object(forKey: "User") as! String
        let group = userDefaults.object(forKey: "Group") as! String
        let point = RealmManager.shared.getTotalPoint()

        FirebaseManager.shared.sendDoneTask(name: name, group: group, point: point, completion: {
            DispatchQueue.main.async {
                self.showAlert(title: "タスクの送信完了", message: "お疲れさまでした")
                // メソッド呼び出し前にselectIndexがnilでないことは保証されているため強制アンラップ
                let indexPath = IndexPath(row: self.selectIndex!, section: 0)
                // セルの選択を解除
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.selectIndex = nil
            }
        })
    }

    private func reload() {
        tableView.reloadData()
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
        selectIndex = indexPath.row
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
