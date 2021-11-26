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

    private let db = Firestore.firestore()
    private var taskListener: ListenerRegistration?
    private let userDefaults = UserDefaults.standard

    private var userPointList: [UserInfo] = [
        UserInfo(name: "ほげ", point: 20)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DashboardTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "DashboardCell")

        setListener()
    }
}

extension DashboardViewController {
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
}
