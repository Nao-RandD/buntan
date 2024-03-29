//
//  DashboardViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/14.
//

import Foundation
import Firebase
import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupLabel: UILabel!

    private let db = Firestore.firestore()
    private var taskListener: ListenerRegistration?
    private let userDefaults = UserDefaults.standard
    private var userPointList: [UserInfo] = [
        UserInfo(name: "ほげ", point: 20)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ランキング"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DashboardTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "DashboardCell")

        setListener()

        // グループ名を設定
        let group = self.userDefaults.object(forKey: "Group") as! String
        groupLabel.text = group

        /// NotificationCenterを登録
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadScreen),
                                               name: .notifyName,
                                               object: nil)
    }
}

extension DashboardViewController {
    @objc func reloadScreen(notification: Notification?) {
        print("\(String(describing: notification))からの通知でグループが変更されたのでリロード")
        let group = self.userDefaults.object(forKey: "Group") as! String
        self.groupLabel.text = group
        setListener()
        reload()
    }

    private func setListener() {
        self.taskListener = db.collection("users").addSnapshotListener { snapshot, e in
                if let snapshot = snapshot {
                    let group = self.userDefaults.object(forKey: "Group") as! String
                    let tasks = snapshot.documents.filter { $0["group"] as! String == group }

                    self.userPointList = tasks.map { task -> UserInfo in
                        return UserInfo(name: task["name"] as! String, point: task["point"] as! Int)
                    }

                    self.tableView.reloadData()
                }
            }
    }

    private func reload() {
        tableView.reloadData()
    }

}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPointList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardTableViewCell
        userPointList = userPointList.sorted(by: { lUser, rUser -> Bool in
            return lUser.point > rUser.point
        })
        // カスタムセルにRealmの情報を反映
        cell.configure(user: userPointList[indexPath.row].name,
                       point: userPointList[indexPath.row].point)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // fetch the animation from the TableAnimation enum and initialze the TableViewAnimator class
        let animation = TableAnimation.moveUpBounce(rowHeight: 150, duration: 1.5, delay: 0.05).getAnimation()
        let animator = TableViewAnimator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
}
