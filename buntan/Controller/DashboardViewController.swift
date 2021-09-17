//
//  DashboardViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/14.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var userPointList: [UserInfo] = [
        UserInfo(name: "Shin", point: 20),
        UserInfo(name: "Nao", point: 40),
        UserInfo(name: "Ryoya", point: 30)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DashboardTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "DashboardCell")

//        let user1 = User(name: "Shin", point: 20)
//        let user2 = User(name: "Nao", point: 40)
//        let user3 = User(name: "Ryoya", point: 30)
//
//        userPointList.append(user1)
//        userPointList.append(user2)
//        userPointList.append(user3)
    }

}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPointList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardTableViewCell
        // カスタムセルにRealmの情報を反映
        cell.configure(user: userPointList[indexPath.row].name,
                       point: userPointList[indexPath.row].point)
        return cell
    }
}
